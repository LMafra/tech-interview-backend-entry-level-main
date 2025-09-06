# frozen_string_literal: true

class AddProductIdToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :cart_items, :product, null: false, foreign_key: true
  end
end
