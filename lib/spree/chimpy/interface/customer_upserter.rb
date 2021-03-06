module Spree::Chimpy
  module Interface
    class CustomerUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(order)
        @order = order
      end
      # CUSTOMER will be pulled first from the MC_EID if present on the order.source
      # IF that is not found, customer will be found by our Customer ID
      # IF that is not found, customer is created with the order email and our Customer ID
      def ensure_and_upsert_customer
        # use the one from mail chimp or fall back to the order's email
        # happens when this is a new user
        customer_id = upsert_from_eid(@order.source.email_id) if @order.source
        customer_id || upsert_from_order
      end

      def self.mailchimp_customer_id(email)
        "customer_#{email}"
      end

      private

      # Retrieves and upserts the customer from the Mailchimp Email ID
      #
      # Parameters:
      #   mc_eid - String
      def upsert_from_eid(mc_eid)
        email = Spree::Chimpy.list.email_for_id(mc_eid)
        if email
          begin
            upsert_customer_merge_vars
            response = store_api_call
              .customers
              .retrieve(params: { "fields" => "customers.id", "email_address" => email })

            data = response["customers"].first
            data["id"] if data
          rescue Gibbon::MailChimpError
            nil
          end
        end
      end

      # Retrieves and upserts the customer using the user ID from the order
      def upsert_from_order
        return unless @order.email

        upsert_customer_merge_vars

        customer_id = self.class.mailchimp_customer_id(@order.email)
        begin
          response = store_api_call
            .customers(customer_id)
            .retrieve(params: { "fields" => "id,email_address"})
        rescue Gibbon::MailChimpError
          # Customer Not Found, so create them
          response = store_api_call
            .customers
            .create(body: {
              id: customer_id,
              email_address: @order.email.downcase,
              opt_in_status: Spree::Chimpy::Config.subscribe_to_list || false
            })
        end
        customer_id
      end

      def upsert_customer_merge_vars
        if @order.user
          merge_vars = {}
          Config.after_purchase_user_merge_vars.map do |key, method_name|
            merge_vars[key] = transform_values(@order.user.send(method_name))
          end
        end

        Spree::Chimpy.list.subscribe(@order.email.downcase, merge_vars)
      end

      # Accepts:
      #   value - any
      def transform_values(value)
        case value
        when Time, Date, DateTime, ActiveSupport::TimeWithZone
          value.strftime(Config.after_purchase_time_formatting)
        else
          value.to_s
        end
      end
    end
  end
end
