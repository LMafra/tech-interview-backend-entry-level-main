# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    cart = Cart.find_by(id: session[:cart_id])
    if cart
      render json: cart.to_json
    else
      render json: { error: "Cart not found" }, status: :not_found
    end
  end

  def create
    cart = Cart.find_or_create_for_session(session)
    product = Product.find_by(id: cart_params[:product_id])

    result = cart.add_product(product, cart_params[:quantity].to_i)

    if result[:success]
      render json: cart.to_json, status: :created
    else
      render json: { error: result[:error] || result[:errors] },
             status: result[:error] == "Product not found" ? :not_found : :unprocessable_entity
    end
  end

  def add_item
    cart = Cart.find_by(id: session[:cart_id])

    unless cart
      render json: { error: "Cart not found" }, status: :not_found
      return
    end

    product = Product.find_by(id: cart_params[:product_id])

    result = cart.add_product(product, cart_params[:quantity].to_i)

    if result[:success]
      render json: cart.to_json, status: :ok
    else
      render json: { error: result[:error] || result[:errors] },
             status: result[:error] == "Product not found" ? :not_found : :unprocessable_entity
    end
  end

  def remove_item
    cart = Cart.find_by(id: session[:cart_id])
    product = Product.find_by(id: params[:product_id])

    result = cart.remove_product(product)

    if result[:success]
      render json: cart.to_json, status: :ok
    else
      render json: { error: result[:error] || result[:errors] },
             status: result[:error] == "Product not found" ? :not_found : :unprocessable_entity
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end
end
