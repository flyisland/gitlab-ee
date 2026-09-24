# frozen_string_literal: true

module JH
  module Projects
    module JobsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

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
