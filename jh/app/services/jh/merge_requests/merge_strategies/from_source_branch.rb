# frozen_string_literal: true

module JH
  module MergeRequests
    module MergeStrategies
      module FromSourceBranch
        extend ::Gitlab::Utils::Override

        override :squash_sha!
        def squash_sha!
          return super unless ::Feature.enabled?(:single_squash_merge_ff, project)
          return super unless project.merge_method == :single_squash_merge

          result = ::MergeRequests::SingleSquashService.new(
            merge_request: merge_request,
            current_user: current_user,
            commit_message: merge_params[:squash_commit_message]
          ).execute

          case result[:status]
          when :success
            result[:squash_sha]
          when :error
            raise_error(result[:message])
          end
        end
      end
    end
  end
end
