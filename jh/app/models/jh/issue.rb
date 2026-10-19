# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Issue
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable
      validates :title, :description, content_validation: true, if: :with_project_should_validate_content?
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      def contains_chinese?(branch_name)
        !!(branch_name =~ /\p{Han}/)
      end

      def pinyin_parameterize(text)
        return text unless contains_chinese?(text)

        text.to_s.split('').map do |character|
          contains_chinese?(character) ? "#{Pinyin.t(character)}-" : character
        end.join
      end

      override :to_branch_name
      def to_branch_name(id, title, project: nil, current_user: nil)
        title = pinyin_parameterize(title)

        super
      end
    end
  end
end
