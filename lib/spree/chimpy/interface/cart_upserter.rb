module Spree::Chimpy
  module Interface
    class CartUpserter < OrderUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(order)
        raise "OrderAlreadyPurchased" if order.complete?

        @order = order
        @create_method = :carts
      end

      private

      def context_specific_data
        {}
      end
    end
  end
end
