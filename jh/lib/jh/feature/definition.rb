# frozen_string_literal: true

module JH
  module Feature
    module Definition
      module ClassMethods
        extend ::Gitlab::Utils::Override

        override :paths
        def paths
          @jh_paths ||= [Rails.root.join('jh/config/feature_flags/**/*.yml')] + super
        end
      end

      def self.prepended(base)
        base.singleton_class.prepend ClassMethods
      end
    end
  end
end
