# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module AuthFinders
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :api_request?
        def api_request?
          super || current_request.path.ends_with?('.json') || current_request.path.ends_with?('.csv')
        end
      end
    end
  end
end
