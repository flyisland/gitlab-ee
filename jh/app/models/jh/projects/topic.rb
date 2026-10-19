# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Projects
    module Topic
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        include ContentValidateable
        validates :name, content_validation: true, if: :should_validate_content?
      end

      private

      override :validate_name_format
      def validate_name_format
        return if name.blank?

        # /\R/ - A linebreak: \n, \v, \f, \r \u0085 (NEXT LINE),
        # \u2028 (LINE SEPARATOR), \u2029 (PARAGRAPH SEPARATOR) or \r\n.
        return unless /\R/.match?(name)

        errors.add(:name, 'has characters that are not allowed')
      end
    end
  end
end
