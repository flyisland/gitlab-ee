# frozen_string_literal: true

module Integrations
  module OnesSerializers
    class IssueSerializer < BaseSerializer
      include WithPagination

      entity ::Integrations::OnesSerializers::IssueEntity
    end
  end
end
