class ChatsController < ApplicationController
  def index
    @chats = current_user.chats
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(user: current_user)
    if @chat.save
      redirect_to chat_path(@chat), notice: "Chat created successfully."
    else
      @chats = current_user.chats
      render :index
    end
  end

  def show
    @chat = Chat.find(params[:id])
    @message = Message.new
  end
end
