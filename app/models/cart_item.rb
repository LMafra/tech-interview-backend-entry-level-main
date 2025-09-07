# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates_numericality_of :quantity, greater_than: 0

  def increment_quantity(amount)
    self.quantity += amount
    save!
  end

  def to_json(*_args)
    {
      id: product.id,
      name: product.name,
      quantity: quantity,
      unit_price: product.price.to_f,
      total_price: (quantity * product.price).to_f
    }
  end
end
