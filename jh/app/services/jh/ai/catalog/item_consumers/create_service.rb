# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      module ItemConsumers
        module CreateService
          extend ::Gitlab::Utils::Override

          private

          override :service_account_name
          def service_account_name
            return 'JihuLab Duo' if jh_advanced_code_review?

            super
          end

          override :service_account_username
          def service_account_username
            return 'JihuLabDuo' if jh_advanced_code_review?

            super
          end

          def jh_advanced_code_review?
            item.foundational_flow_reference ==
              ::JH::Ai::Catalog::FoundationalFlow::JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE
          end
        end
      end
    end
  end
end
