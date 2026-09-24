# frozen_string_literal: true

module Integrations
  module LigaaiSerializers
    class IssueSerializer < BaseSerializer
      include WithPagination

      entity ::Integrations::LigaaiSerializers::IssueEntity
    end
  end
end
