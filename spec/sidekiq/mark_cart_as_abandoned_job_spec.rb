# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    context 'when called with a cart_id' do
      let(:cart) { create(:cart, status: 'active', updated_at: 4.hours.ago) }

      it 'enqueues MarkSingleCartAsAbandonedJob for the specific cart' do
        expect(MarkSingleCartAsAbandonedJob).to receive(:perform_async).with(cart.id)

        described_class.new.perform(cart.id)
      end
    end

    context 'when called without a cart_id (bulk processing)' do
      let!(:active_recent_cart) { create(:cart, status: 'active', updated_at: 1.hour.ago) }
      let!(:active_old_cart) { create(:cart, status: 'active', updated_at: 4.hours.ago) }
      let!(:abandoned_recent_cart) { create(:cart, status: 'abandoned', updated_at: 1.day.ago) }
      let!(:abandoned_old_cart) { create(:cart, status: 'abandoned', updated_at: 8.days.ago) }

      it 'enqueues jobs for old active carts' do
        expect(MarkSingleCartAsAbandonedJob).to receive(:perform_async).with(active_old_cart.id)
        expect(MarkSingleCartAsAbandonedJob).not_to receive(:perform_async).with(active_recent_cart.id)

        described_class.new.perform
      end

      it 'enqueues jobs for old abandoned carts' do
        expect(DeleteOldAbandonedCartJob).to receive(:perform_async).with(abandoned_old_cart.id)
        expect(DeleteOldAbandonedCartJob).not_to receive(:perform_async).with(abandoned_recent_cart.id)

        described_class.new.perform
      end
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
