# frozen_string_literal: true

module JH
  module Projects
    module ApplicationController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      private

      override :require_pages_enabled!
      def require_pages_enabled!
        not_found unless @project.pages_available?
      end
    end
  end
end
