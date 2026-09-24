# frozen_string_literal: true

# Prepended onto ::QA::Runtime::User
module QA
  module JH
    module Runtime
      module User
        def phone
          ::QA::Runtime::Env.user_phone
        end
      end
    end
  end
end
