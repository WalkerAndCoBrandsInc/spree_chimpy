Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  state_machine do
    after_transition :to => :complete, :do => :notify_mailchimp_order_complete
  end

  around_save :handle_cancelation

  scope :updated_since_yesterday, -> { where("updated_at >= ?", Time.zone.yesterday) }

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
