class AddIndexToPropertiesPublicId < ActiveRecord::Migration[7.1]
  def change
    add_index :properties, :public_id, unique: true
  end
end
