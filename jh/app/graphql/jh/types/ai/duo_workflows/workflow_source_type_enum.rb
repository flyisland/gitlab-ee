# frozen_string_literal: true

module JH
  module Types
    module Ai
      module DuoWorkflows
        module WorkflowSourceTypeEnum
          extend ActiveSupport::Concern

          prepended do
            value 'DINGTALK', value: 'dingtalk', description: 'Session initiated from DingTalk.'
            value 'FEISHU', value: 'feishu', description: 'Session initiated from Feishu.'
          end
        end
      end
    end
  end
end
