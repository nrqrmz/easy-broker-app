class Property < ApplicationRecord
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
end
