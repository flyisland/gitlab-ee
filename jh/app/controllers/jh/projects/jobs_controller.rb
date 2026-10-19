# frozen_string_literal: true

module JH
  module Projects
    module JobsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        skip_before_action :authorize_update_build!, only: [:update_tags]
      end

      def update_tags
        return access_denied! unless ::Ci::UpdateJobTagsService.permitted?(@build, current_user: current_user)

        result = ::Ci::UpdateJobTagsService.new(
          @build, current_user: current_user, tags: params.permit(tags: [])[:tags]
        ).execute

        if result.success?
          render json: result.payload
        else
          render json: { message: result.message }, status: result.reason
        end
      end

      private

      override :raw_redirect_params
      def raw_redirect_params
        return super unless ::Feature.enabled?(:jh_hidden_oss_content_type, project)

        # Aliyun OSS rejects signed URLs that override Content-Type (error 0017-00000902).
        { query: { 'response-content-disposition' => 'inline' } }
      end
    end
  end
end
