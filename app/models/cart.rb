# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def self.find_or_create_for_session(session)
    if session[:cart_id]
      find_by(id: session[:cart_id]) || create_for_session(session)
    else
      create_for_session(session)
    end
  end

  def self.create_for_session(session)
    cart = create!(total_price: 0)
    session[:cart_id] = cart.id
    cart
  end

  def add_product(product, quantity)
    return { success: false, error: "Product not found" } unless product

    existing_item = find_item_for_product(product)

    if existing_item
      existing_item.increment_quantity(quantity)
    else
      cart_items.build(product: product, quantity: quantity)
    end

    if save
      update_total_price!
      { success: true }
    else
      { success: false, errors: errors }
    end
  end

  def remove_product(product)
    return { success: false, error: "Product not found" } unless product

    cart_items.find { |item| item.product.id == product.id }.destroy
    { success: true }
  end

  def to_json
    {
      id: id,
      products: cart_items.includes(:product).map(&:to_json),
      total_price: total_price.to_f
    }
  end

  def update_total_price!
    update!(total_price: cart_items.sum { |item| item.quantity * item.product.price })
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  private

  def find_item_for_product(product)
    cart_items.find { |item| item.product.id == product.id }
  end
end
