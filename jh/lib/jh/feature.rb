# frozen_string_literal: true

module JH
  module Feature
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :build_flipper_instance
      def build_flipper_instance(memoize: false)
        ::Flipper.new(flipper_adapter).tap do |flip|
          flip.memoize = memoize
        end
      end

      private

      def flipper_adapter
        active_record_adapter = ::Flipper::Adapters::ActiveRecord.new(
          feature_class: ::Feature::FlipperFeature,
          gate_class: ::Feature::FlipperGate)

        # Redis L2 cache
        redis_cache_adapter =
          ::Feature::ActiveSupportCacheStoreAdapter.new(
            active_record_adapter,
            l2_cache_backend,
            1.hour,
            write_through: true)

        return redis_cache_adapter if ::Gitlab::Utils.to_boolean(ENV['DISABLE_FF_PROCESS_MEMORY_CACHE'])

        # Thread-local L1 cache: use a short timeout since we don't have a
        # way to expire this cache all at once
        ::Flipper::Adapters::ActiveSupportCacheStore.new(
          redis_cache_adapter,
          l1_cache_backend,
          1.minute)
      end
    end
  end
end
