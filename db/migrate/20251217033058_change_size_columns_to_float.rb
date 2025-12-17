class ChangeSizeColumnsToFloat < ActiveRecord::Migration[7.1]
  def change
    change_column :properties, :lot_size, :float
    change_column :properties, :construction_size, :float
  end
end
