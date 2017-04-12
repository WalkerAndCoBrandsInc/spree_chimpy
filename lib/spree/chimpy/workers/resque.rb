module Spree::Chimpy
  module Workers
    class Resque
      delegate :log, to: Spree::Chimpy

      QUEUE = :default
      @queue = QUEUE

      def self.perform(payload)
        Spree::Chimpy.perform(payload.with_indifferent_access)
      end
    end
  end
end
