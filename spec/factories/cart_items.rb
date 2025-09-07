# frozen_string_literal: true

FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { Faker::Number.between(from: 1, to: 5) }

    trait :multiple_quantity do
      quantity { Faker::Number.between(from: 5, to: 10) }
    end

    trait :large_quantity do
      quantity { Faker::Number.between(from: 10, to: 50) }
    end

    trait :small_quantity do
      quantity { Faker::Number.between(from: 1, to: 3) }
    end

    trait :with_expensive_product do
      association :product, :expensive
    end

    trait :with_cheap_product do
      association :product, :cheap
    end

    trait :with_electronics_product do
      association :product, :electronics
    end

    trait :with_clothing_product do
      association :product, :clothing
    end

    trait :with_food_product do
      association :product, :food
    end

    trait :recently_added do
      created_at { Faker::Time.between(from: 1.hour.ago, to: Time.current) }
    end

    trait :old_item do
      created_at { Faker::Time.between(from: 7.days.ago, to: 1.day.ago) }
    end
  end
end
