class CreateProperties < ActiveRecord::Migration[7.1]
  def change
    create_table :properties do |t|
      t.string :public_id
      t.string :title
      t.text :description
      t.string :property_type
      t.string :location
      t.string :region
      t.string :city
      t.string :city_area
      t.string :street
      t.string :postal_code
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :half_bathrooms
      t.integer :parking_spaces
      t.decimal :lot_size
      t.decimal :construction_size
      t.string :operation_type
      t.decimal :price
      t.string :currency, default: 'MXN'
      t.string :title_image_full
      t.string :title_image_thumb
      t.jsonb :features, default: []

      t.timestamps
    end
  end
end
