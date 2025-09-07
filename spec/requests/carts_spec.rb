# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts', type: :request do
  let(:valid_attributes) do
    {
      product_id: 1,
      quantity: 2
    }
  end

  let(:invalid_attributes) do
    {
      product_id: 99_999,
      quantity: 1
    }
  end

  let(:valid_headers) do
    {}
  end

  let(:product) { Product.create!(name: 'Test Product', price: 10.0) }

  describe 'GET /show' do
    context 'when cart exists' do
      it 'renders a successful response' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

        get '/cart', headers: valid_headers, as: :json
        expect(response).to be_successful
      end
    end

    context 'when cart does not exist' do
      it 'renders a not found response' do
        get '/cart', headers: valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Cart' do
        expect do
          post '/cart',
               params: { product_id: product.id, quantity: 2 }, headers: valid_headers, as: :json
        end.to change(Cart, :count).by(1)
      end

      it 'renders a JSON response with the new cart' do
        post '/cart',
             params: { product_id: product.id, quantity: 2 }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'adds product to cart' do
        post '/cart',
             params: { product_id: product.id, quantity: 2 }, headers: valid_headers, as: :json
        json_response = JSON.parse(response.body)
        expect(json_response['products'].length).to eq(1)
        expect(json_response['products'].first['quantity']).to eq(2)
        expect(json_response['total_price']).to eq(20.0)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the new cart' do
        post '/cart',
             params: { product_id: 99_999, quantity: 1 }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when adding same product multiple times' do
      it 'increments quantity of existing product' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['products'].length).to eq(1)
        expect(json_response['products'].first['quantity']).to eq(5)
        expect(json_response['total_price']).to eq(50.0)
      end
    end
  end

  describe 'POST /add_item' do
    context 'with valid parameters' do
      it 'adds product to existing cart' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        cart_id = JSON.parse(response.body)['id']

        post '/cart/add_item', params: { product_id: product.id, quantity: 3 }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(cart_id)
        expect(json_response['products'].length).to eq(1)
        expect(json_response['products'].first['quantity']).to eq(5)
        expect(json_response['total_price']).to eq(50.0)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors when cart does not exist' do
        post '/cart/add_item',
             params: { product_id: product.id, quantity: 1 }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Cart not found')
      end

      it 'renders a JSON response with errors when product not found' do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

        post '/cart/add_item',
             params: { product_id: 99_999, quantity: 1 }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
