class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    if @chat.ask(params[:message][:content])
      redirect_to chat_path(@chat)
    else
      @message = @chat.messages.last
      render "chats/show", status: :unprocessable_entity
    end
  end
end
