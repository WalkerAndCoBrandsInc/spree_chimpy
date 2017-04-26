module Spree::Chimpy
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,                       :string,  default: 'spree'
    preference :subscribed_by_default,          :boolean, default: false
    preference :subscribe_to_list,              :boolean, default: false
    preference :key,                            :string
    preference :list_name,                      :string,  default: 'Members'
    preference :list_id,                        :string,  default: nil
    preference :customer_segment_name,          :string,  default: 'Customers'
    preference :merge_vars,                     :hash,    default: { 'EMAIL' => :email }
    preference :api_options,                    :hash,    default: { timeout: 60 }
    preference :double_opt_in,                  :boolean, default: false
    preference :send_welcome_email,             :boolean, default: true
    preference :delay_before_sending,           :integer, default: 4.minutes
    preference :after_purchase_user_merge_vars, :hash,    default: {}
    preference :after_purchase_time_formatting, :string,  default: "%m/%d/%Y"
  end
end
