# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteOldAbandonedCartJob, type: :job do
  describe '#perform' do
    let(:cart) { create(:cart, status: 'abandoned', updated_at: 8.days.ago) }

    it 'deletes the cart if it is old and abandoned' do
      expect { described_class.new.perform(cart.id) }
        .to change { Cart.exists?(cart.id) }.from(true).to(false)
    end

    it 'does not delete the cart if it is recent' do
      cart.update!(updated_at: 1.day.ago)

      expect { described_class.new.perform(cart.id) }
        .not_to(change { Cart.exists?(cart.id) })
    end

    it 'does not delete the cart if it is not abandoned' do
      cart.update!(status: 'active')

      expect { described_class.new.perform(cart.id) }
        .not_to(change { Cart.exists?(cart.id) })
    end

    it 'does not process if cart is not found' do
      expect { described_class.new.perform(99_999) }
        .not_to raise_error
    end
  end

  describe 'retry configuration' do
    it 'has retry configured' do
      expect(described_class.sidekiq_options['retry']).to eq(3)
    end

    it 'has queue configured' do
      expect(described_class.sidekiq_options['queue']).to eq('default')
    end
  end
end
