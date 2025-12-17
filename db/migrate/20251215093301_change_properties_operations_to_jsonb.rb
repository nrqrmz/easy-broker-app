class ChangePropertiesOperationsToJsonb < ActiveRecord::Migration[7.1]
  def change
    remove_column :properties, :operation_type, :string
    remove_column :properties, :price, :decimal
    remove_column :properties, :currency, :string, default: 'MXN'
    add_column :properties, :operations, :jsonb, default: []
  end
end
