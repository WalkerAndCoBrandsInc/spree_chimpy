module Spree::Chimpy
  module Interface
    class Carts < Orders
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize
        @upserter_class = CartUpserter
        @create_method  = :carts
      end
    end
  end
end
