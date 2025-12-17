class Property < ApplicationRecord
  has_neighbors :embedding

  validates :public_id, presence: true, uniqueness: true

  def for_sale?
    operations.any? { |op| op['type'] == 'sale' }
  end

  def for_rent?
    operations.any? { |op| op['type'] == 'rental' }
  end

  def sale_operation
    operations.find { |op| op['type'] == 'sale' }
  end

  def rental_operation
    operations.find { |op| op['type'] == 'rental' }
  end

  def sale_price
    sale_operation&.dig('price')
  end

  def rental_price
    rental_operation&.dig('price')
  end

  def sale_currency
    sale_operation&.dig('currency') || 'MXN'
  end

  def rental_currency
    rental_operation&.dig('currency') || 'MXN'
  end

  private

  def set_embedding
    content = [
      "Property title: #{title}",
      "Property description: #{description}",
      "Property type: #{property_type}",
      "Location: #{location}",
      "Region: #{region}",
      "City: #{city}",
      "City area: #{city_area}",
      ("Bedrooms: #{bedrooms}" if bedrooms.present?),
      ("Bathrooms: #{bathrooms}" if bathrooms.present?),
      ("Parking spaces: #{parking_spaces}" if parking_spaces.present?),
      ("Lot size: #{lot_size} m²" if lot_size.present?),
      ("Construction size: #{construction_size} m²" if construction_size.present?),
      ("Features: #{features.join(', ')}" if features.present?),
      (operations.map { |op| "#{op['type']}: #{op['price']} #{op['currency']}" }.join(", ") if operations.present?)
    ].compact.join(". ")
    embedding = RubyLLM.embed(content)
    update(embedding: embedding.vectors)
  end
end
