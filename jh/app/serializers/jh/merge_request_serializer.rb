# frozen_string_literal: true

module JH
  module MergeRequestSerializer
    extend ::Gitlab::Utils::Override

    override :represent
    def represent(merge_request, opts = {}, entity = nil)
      entity = ::MergeRequests::MergeRequestMonorepoEntity if opts[:serializer] == 'monorepo'

      super
    end
  end
end
