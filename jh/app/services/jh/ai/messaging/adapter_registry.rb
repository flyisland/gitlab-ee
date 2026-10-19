# frozen_string_literal: true

module JH
  module Ai
    module Messaging
      # JH additions to the upstream frozen ADAPTERS hash; upstream changes to
      # the hash must be mirrored here until a register extension point exists
      # upstream. The module is prepended purely for the self.prepended hook --
      # it adds no instance methods of its own.
      module AdapterRegistry
        def self.prepended(base)
          adapters = base::ADAPTERS.merge(
            ::Ai::Messaging::Adapters::Dingtalk.adapter_key => ::Ai::Messaging::Adapters::Dingtalk,
            ::Ai::Messaging::Adapters::Feishu.adapter_key => ::Ai::Messaging::Adapters::Feishu
          )

          base.send(:remove_const, :ADAPTERS) # rubocop:disable GitlabSecurity/PublicSend -- constant
          base.const_set(:ADAPTERS, adapters.freeze)
        end
      end
    end
  end
end
