# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:cart_items) }
    it { should have_many(:carts).through(:cart_items) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:product)).to be_valid
    end

    it 'creates products with different traits' do
      expensive_product = create(:product, :expensive)
      cheap_product = create(:product, :cheap)
      electronics_product = create(:product, :electronics)
      clothing_product = create(:product, :clothing)
      food_product = create(:product, :food)

      expect(expensive_product.price).to be >= 100
      expect(cheap_product.price).to be <= 10
      expect(electronics_product.name).to include('-')
      expect(clothing_product.name).to be_present
      expect(food_product.name).to be_present
    end
  end
end
