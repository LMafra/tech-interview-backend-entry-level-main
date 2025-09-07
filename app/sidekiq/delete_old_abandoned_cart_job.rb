# frozen_string_literal: true

class DeleteOldAbandonedCartJob
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

    if cart.status == 'abandoned' && cart.updated_at < 7.days.ago
      cart.destroy!
      Rails.logger.info "Deleted old abandoned cart #{cart_id}"
    end
  rescue StandardError => e
    Rails.logger.error "DeleteOldAbandonedCartJob failed for cart #{cart_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
