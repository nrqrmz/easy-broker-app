class AddToolCallIdToToolCalls < ActiveRecord::Migration[7.1]
  def change
    add_column :tool_calls, :tool_call_id, :string
  end
end
