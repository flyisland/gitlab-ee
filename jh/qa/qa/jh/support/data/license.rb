# frozen_string_literal: true

module QA
  module JH
    module Support
      module Data
        module License
          # @override license_user
          def license_user
            'Jihulab QA'
          end

          # @override license_company
          def license_company
            '极狐(GitLab)'
          end

          # @override license_plan
          def license_plan
            {
              name: "Ultimate",
              company: "极狐(GitLab)",
              plan: "Ultimate"
            }
          end
        end
      end
    end
  end
end
