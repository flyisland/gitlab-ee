# frozen_string_literal: true

module JH
  module MergeRequests
    module PushOptionsHandlerService
      extend ::Gitlab::Utils::Override

      override :base_params
      def base_params
        params = super

        if push_options.key?(:skip_mono_central_pipeline)
          params[:skip_mono_central_pipeline] = push_options[:skip_mono_central_pipeline]
        end

        params
      end

      private :base_params
    end
  end
end
