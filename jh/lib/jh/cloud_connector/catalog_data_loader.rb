# frozen_string_literal: true

module JH
  module CloudConnector
    module CatalogDataLoader
      extend ::Gitlab::Utils::Override

      override :use_yaml_data_loader?
      def use_yaml_data_loader?
        return true if ::Feature.enabled?(:jh_enable_upload_cloud_license)

        super
      end
    end
  end
end
