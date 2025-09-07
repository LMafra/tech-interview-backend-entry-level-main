# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkSingleCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let(:cart) { create(:cart, status: 'active', updated_at: 4.hours.ago) }

    it 'marks the cart as abandoned and schedules deletion' do
      expect(DeleteOldAbandonedCartJob).to receive(:perform_in).with(7.days, cart.id)

      expect { described_class.new.perform(cart.id) }
        .to change { cart.reload.status }.from('active').to('abandoned')
    end

    it 'does not process if cart is still active' do
      cart.update!(updated_at: 1.hour.ago)

      expect(DeleteOldAbandonedCartJob).not_to receive(:perform_in)

      expect { described_class.new.perform(cart.id) }
        .not_to(change { cart.reload.status })
    end

    it 'does not process if cart is not found' do
      expect { described_class.new.perform(99_999) }
        .not_to raise_error
    end

    it 'does not process if cart is already abandoned' do
      cart.update!(status: 'abandoned')

      expect(DeleteOldAbandonedCartJob).not_to receive(:perform_in)

      expect { described_class.new.perform(cart.id) }
        .not_to(change { cart.reload.status })
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
