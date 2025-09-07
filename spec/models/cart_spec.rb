require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
    it { should validate_inclusion_of(:status).in_array(%w[active abandoned]) }
  end

  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cart)).to be_valid
    end

    it 'creates carts with different traits' do
      abandoned_cart = create(:cart, :abandoned)
      cart_with_items = create(:cart, :with_items, items_count: 3)
      high_total_cart = create(:cart, :with_high_total)
      recent_cart = create(:cart, :recently_created)
      old_cart = create(:cart, :old_cart)

      expect(abandoned_cart.status).to eq('abandoned')
      expect(cart_with_items.cart_items.count).to eq(3)
      expect(high_total_cart.total_price).to be >= 500
      expect(recent_cart.created_at).to be > 1.day.ago
      expect(old_cart.created_at).to be < 7.days.ago
    end
  end

  describe 'class methods' do
    describe '.find_or_create_for_session' do
      let(:session) { {} }

      context 'when no cart_id in session' do
        it 'creates a new cart' do
          expect { Cart.find_or_create_for_session(session) }.to change(Cart, :count).by(1)
        end

        it 'sets cart_id in session' do
          cart = Cart.find_or_create_for_session(session)
          expect(session[:cart_id]).to eq(cart.id)
        end
      end

      context 'when cart_id exists in session' do
        let!(:existing_cart) { create(:cart) }
        let(:session) { { cart_id: existing_cart.id } }

        it 'returns the existing cart' do
          expect(Cart.find_or_create_for_session(session)).to eq(existing_cart)
        end

        it 'does not create a new cart' do
          expect { Cart.find_or_create_for_session(session) }.not_to change(Cart, :count)
        end
      end
    end
  end

  describe 'instance methods' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    describe '#add_product' do
      context 'with valid product' do
        it 'adds product to cart' do
          result = cart.add_product(product, 2)
          expect(result[:success]).to be true
          expect(cart.cart_items.count).to eq(1)
          expect(cart.cart_items.first.quantity).to eq(2)
        end

        it 'updates total price' do
          cart.add_product(product, 2)
          expect(cart.total_price).to eq(product.price * 2)
        end
      end

      context 'with invalid product' do
        it 'returns error' do
          result = cart.add_product(nil, 2)
          expect(result[:success]).to be false
          expect(result[:error]).to eq("Product not found")
        end
      end
    end

    describe '#remove_product' do
      before { cart.add_product(product, 2) }

      it 'removes product from cart' do
        result = cart.remove_product(product)
        expect(result[:success]).to be true
        expect(cart.cart_items.count).to eq(0)
      end
    end

    describe '#update_total_price!' do
      before do
        cart.add_product(create(:product, price: 10), 2)
        cart.add_product(create(:product, price: 5), 3)
      end

      it 'calculates correct total' do
        cart.update_total_price!
        expect(cart.total_price).to eq(35)
      end
    end
  end
end
