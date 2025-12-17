class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :role
      t.references :chat, null: false, foreign_key: true
      t.text :content
      t.string :model_id
      t.integer :input_tokens
      t.integer :output_tokens

      t.timestamps
    end
  end
end
