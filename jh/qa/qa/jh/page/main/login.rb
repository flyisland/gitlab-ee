# frozen_string_literal: true

module QA
  module JH
    module Page
      module Main
        module Login
          # @override :fill_in_credential
          def fill_in_credential(user)
            username_to_use = if user.respond_to?(:phone) && user.phone.present?
                                user.phone
                              else
                                user.username
                              end

            fill_element 'username-field', username_to_use
            fill_element 'password-field', user.password
          end
        end
      end
    end
  end
end
