class MessagesController < ApplicationController
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  def create
    @chat = Chat.find(params[:chat_id])

    ip_address = Rails.env.development? ? '177.240.124.174' : request.remote_ip
    location_tool = LocationTool.new(ip_address: ip_address)

    embedding = RubyLLM.embed(params[:message][:content])
    properties = Property.nearest_neighbors(:embedding, embedding.vectors, distance: 'euclidean').first(3)

    instructions = system_prompt
    instructions += properties.map { |property| property_prompt(property) }.join("\n\n")

    @assistant_message = nil
    @accumulated_content = ""
    @first_chunk = true

    if @chat.with_instructions(instructions)
            .with_tool(location_tool)
            .ask(params[:message][:content]) do |chunk|
              next if chunk.content.blank?

              @accumulated_content += chunk.content

              if @first_chunk
                @assistant_message = @chat.messages.where(role: :assistant).reorder(created_at: :desc).first
                broadcast_streaming_append(@assistant_message, @accumulated_content)
                @first_chunk = false
              else
                broadcast_streaming_replace(@assistant_message, @accumulated_content)
              end
            end

      # Final broadcast with proper partial rendering
      @assistant_message.reload
      broadcast_replace(@assistant_message)

      head :ok
    else
      @message = @chat.messages.last
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def broadcast_streaming_append(message, content)
    Turbo::StreamsChannel.broadcast_append_to(
      @chat,
      target: "messages",
      html: streaming_message_html(message, content)
    )
  end

  def broadcast_streaming_replace(message, content)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat,
      target: helpers.dom_id(message),
      html: streaming_message_html(message, content)
    )
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat,
      target: helpers.dom_id(message),
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def streaming_message_html(message, content)
    markdown_html = render_markdown(content)

    <<~HTML
      <div class="d-flex justify-content-start mb-5" id="#{helpers.dom_id(message)}">
        <div class="px-3 pb-0 pt-3">
          #{markdown_html}
        </div>
      </div>
    HTML
  end

  def system_prompt
    "You are a real estate assistant for EasyBroker. \
      Your task is to help users find properties based on their needs and preferences. \
      Always share the property title, location, price, and key features. \
      If a property has bedrooms, bathrooms, or parking spaces, mention them. \
      If you don't find a suitable property, say so honestly and ask for more details. \
      Respond in the same language the user writes in (Spanish or English). \
      Your answer should be in markdown. \
      IMPORTANT: When mentioning a property, ALWAYS include a markdown link to its detail page using the URL provided. \
      Format property links as: [Property Title](property_url) \
      You have access to a location tool that can determine the user's current location. \
      If the user asks where they are or wants properties near them, use the location tool first. \
      Here are the nearest properties based on the user's question: "
  end

  def property_prompt(property)
    prop_url = property_url(property.public_id, chat_id: @chat.id)

    [
      "PROPERTY public_id: #{property.public_id}",
      "title: #{property.title}",
      "URL: #{prop_url}",
      "type: #{property.property_type}",
      "location: #{property.location}",
      "city: #{property.city}",
      ("bedrooms: #{property.bedrooms}" if property.bedrooms.present?),
      ("bathrooms: #{property.bathrooms}" if property.bathrooms.present?),
      ("parking: #{property.parking_spaces}" if property.parking_spaces.present?),
      ("size: #{property.construction_size} m²" if property.construction_size.present?),
      ("features: #{property.features.join(', ')}" if property.features.present?),
      ("operations: #{property.operations.map { |op| "#{op['type']} - #{op['formatted_price'] || "#{op['price']} #{op['currency']}"}" }.join(', ')}" if property.operations.present?),
      "description: #{property.description.truncate(300)}"
    ].compact.join(", ")
  end
end
