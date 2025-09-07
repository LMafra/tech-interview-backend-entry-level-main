# frozen_string_literal: true

class MarkCartAsAbandonedJob
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

  def perform(cart_id = nil)
    if cart_id
      MarkSingleCartAsAbandonedJob.perform_async(cart_id)
    else
      enqueue_abandoned_cart_cleanup
    end
  rescue StandardError => e
    Rails.logger.error "MarkCartAsAbandonedJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  private

  def enqueue_abandoned_cart_cleanup
    Rails.logger.info 'Starting abandoned cart cleanup job'

    enqueue_carts_for_abandonment
    enqueue_old_carts_for_deletion

    Rails.logger.info 'Completed abandoned cart cleanup job'
  end

  def enqueue_carts_for_abandonment
    Cart.select(:id)
        .where(status: 'active')
        .where('updated_at < ?', 3.hours.ago)
        .find_each(batch_size: 100) do |cart|
      MarkSingleCartAsAbandonedJob.perform_async(cart.id)
    end
  end

  def enqueue_old_carts_for_deletion
    Cart.select(:id)
        .where(status: 'abandoned')
        .where('updated_at < ?', 7.days.ago)
        .find_each(batch_size: 100) do |cart|
      DeleteOldAbandonedCartJob.perform_async(cart.id)
    end
  end
end
