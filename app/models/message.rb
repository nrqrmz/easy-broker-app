class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :tool_call, optional: true

  acts_as_message

  # Only broadcast for user messages - assistant messages are handled by the controller during streaming
  after_create_commit :broadcast_append_to_chat, if: :user_message?

  private

  def user_message?
    role == "user"
  end

  def broadcast_append_to_chat
    broadcast_append_to chat,
                        target: "messages",
                        partial: "messages/message",
                        locals: { message: self }
  end
end
