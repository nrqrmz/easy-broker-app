class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])

    ip_address = Rails.env.development? ? '177.240.124.174' : request.remote_ip
    location_tool = LocationTool.new(ip_address: ip_address)

    embedding = RubyLLM.embed(params[:message][:content])
    properties = Property.nearest_neighbors(:embedding, embedding.vectors, distance: 'euclidean').first(3)

    instructions = system_prompt
    instructions += properties.map { |property| property_prompt(property) }.join("\n\n")

    if @chat.with_instructions(instructions)
            .with_tool(location_tool)
            .ask(params[:message][:content])

      redirect_to chat_path(@chat)
    else
      @message = @chat.messages.last
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def system_prompt
    "You are a real estate assistant for EasyBroker. \
      Your task is to help users find properties based on their needs and preferences. \
      Always share the property title, location, price, and key features. \
      If a property has bedrooms, bathrooms, or parking spaces, mention them. \
      If you don't find a suitable property, say so honestly and ask for more details. \
      Respond in the same language the user writes in (Spanish or English). \
      Your answer should be in markdown. \
      You have access to a location tool that can determine the user's current location. \
      If the user asks where they are or wants properties near them, use the location tool first. \
      Here are the nearest properties based on the user's question: "
end

  def property_prompt(property)
    [
      "PROPERTY public_id: #{property.public_id}",
      "title: #{property.title}",
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
