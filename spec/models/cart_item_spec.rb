# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cart_item)).to be_valid
    end

    it 'creates cart items with different traits' do
      multiple_quantity_item = create(:cart_item, :multiple_quantity)
      large_quantity_item = create(:cart_item, :large_quantity)
      small_quantity_item = create(:cart_item, :small_quantity)
      electronics_item = create(:cart_item, :with_electronics_product)
      clothing_item = create(:cart_item, :with_clothing_product)
      food_item = create(:cart_item, :with_food_product)
      recent_item = create(:cart_item, :recently_added)
      old_item = create(:cart_item, :old_item)

      expect(multiple_quantity_item.quantity).to be >= 5
      expect(large_quantity_item.quantity).to be >= 10
      expect(small_quantity_item.quantity).to be <= 3
      expect(electronics_item.product.name).to include('-')
      expect(clothing_item.product.name).to be_present
      expect(food_item.product.name).to be_present
      expect(recent_item.created_at).to be > 1.hour.ago
      expect(old_item.created_at).to be < 1.day.ago
    end
  end

  describe 'instance methods' do
    let(:cart_item) { create(:cart_item, quantity: 2) }

    describe '#increment_quantity' do
      it 'increases quantity by specified amount' do
        expect { cart_item.increment_quantity(3) }.to change(cart_item, :quantity).from(2).to(5)
      end

      it 'saves the record' do
        cart_item.increment_quantity(3)
        expect(cart_item).to be_persisted
        expect(cart_item.reload.quantity).to eq(5)
      end
    end

    describe '#to_json' do
      let(:product) { create(:product, name: 'Test Product', price: 10.50) }
      let(:cart_item) { create(:cart_item, product: product, quantity: 3) }

      it 'returns correct JSON structure' do
        json = cart_item.to_json

        expect(json[:id]).to eq(product.id)
        expect(json[:name]).to eq('Test Product')
        expect(json[:quantity]).to eq(3)
        expect(json[:unit_price]).to eq(10.50)
        expect(json[:total_price]).to eq(31.50)
      end
    end
  end
end
