# frozen_string_literal: true

class MarkSingleCartAsAbandonedJob
  include Sidekiq::Job

  sidekiq_options retry: 3, queue: 'default'

  sidekiq_retry_in do |count, exception|
    case exception
    when ActiveRecord::RecordNotFound
      false
    else
      count * 30
    end
  end

  def perform(cart_id)
    cart = Cart.find_by(id: cart_id)
    return unless cart

    if cart.status == 'active' && cart.updated_at < 3.hours.ago
      cart.update!(status: 'abandoned')
      DeleteOldAbandonedCartJob.perform_in(7.days, cart_id)
      Rails.logger.info "Marked cart #{cart_id} as abandoned and scheduled for deletion in 7 days"
    end
  rescue StandardError => e
    Rails.logger.error "MarkSingleCartAsAbandonedJob failed for cart #{cart_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
