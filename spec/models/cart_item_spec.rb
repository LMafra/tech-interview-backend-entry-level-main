require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates numericality of quantity' do
      cart_item = described_class.new(quantity: -1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'validates presence of cart' do
      cart_item = described_class.new(quantity: 1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:cart]).to include("must exist")
    end

    it 'validates presence of product' do
      cart_item = described_class.new(quantity: 1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:product]).to include("must exist")
    end
  end
end
