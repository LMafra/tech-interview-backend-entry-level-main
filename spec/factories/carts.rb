# frozen_string_literal: true

FactoryBot.define do
  factory :cart do
    total_price { 0.00 }
    status { 'active' }

    trait :abandoned do
      status { 'abandoned' }
    end

    trait :with_items do
      transient do
        items_count { Faker::Number.between(from: 1, to: 5) }
      end

      after(:create) do |cart, evaluator|
        create_list(:cart_item, evaluator.items_count, cart: cart)
        cart.update_total_price!
      end
    end

    trait :with_high_total do
      total_price { Faker::Commerce.price(range: 500.0..2000.0) }
    end

    trait :with_random_total do
      total_price { Faker::Commerce.price(range: 10.0..500.0) }
    end

    trait :recently_created do
      created_at { Faker::Time.between(from: 1.day.ago, to: Time.current) }
    end

    trait :old_cart do
      created_at { Faker::Time.between(from: 30.days.ago, to: 7.days.ago) }
    end
  end
end
