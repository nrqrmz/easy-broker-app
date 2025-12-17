class AddToolCallToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :tool_call, foreign_key: true
  end
end
