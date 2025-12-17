class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :tool_call, optional: true

  acts_as_message
end
