# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    price { Faker::Commerce.price(range: 1.0..100.0) }

    trait :expensive do
      price { Faker::Commerce.price(range: 100.0..1000.0) }
    end

    trait :cheap do
      price { Faker::Commerce.price(range: 0.1..10.0) }
    end

    trait :with_custom_name do
      name { Faker::Commerce.product_name }
    end

    trait :electronics do
      name { Faker::Commerce.product_name + " - " + Faker::Device.model_name }
      price { Faker::Commerce.price(range: 50.0..2000.0) }
    end

    trait :clothing do
      name { Faker::Commerce.product_name + " - " + Faker::Commerce.color + " " + Faker::Commerce.material }
      price { Faker::Commerce.price(range: 10.0..200.0) }
    end

    trait :food do
      name { Faker::Food.dish }
      price { Faker::Commerce.price(range: 5.0..50.0) }
    end
  end
end
