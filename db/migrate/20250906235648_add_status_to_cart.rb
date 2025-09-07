# frozen_string_literal: true

class AddStatusToCart < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string, default: 'active'
  end
end
