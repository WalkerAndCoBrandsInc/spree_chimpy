Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  state_machine do
    after_transition :to => :complete, :do => :notify_mailchimp_order_complete
  end

  register_update_hook :notify_mailchimp_order_added

  around_save :handle_cancelation

  def notify_mailchimp_order_added
    return unless Spree::Chimpy.configured?
    return unless state == "cart"

    Spree::Chimpy.enqueue(:cart_add, self)
  end

  def notify_mailchimp_order_complete
    return unless Spree::Chimpy.configured?
    return unless completed?

    Spree::Chimpy.enqueue(:order_add, self)
    Spree::Chimpy.enqueue(:cart_delete, self)
  end

  private

  def handle_cancelation
    canceled = state_changed? && canceled?
    yield
    notify_mailchimp_order_complete if canceled
  end
end
