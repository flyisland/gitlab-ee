# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::CatalogDataLoader, feature_category: :plan_provisioning do
  let(:model_class) { ::Gitlab::CloudConnector::DataModel::UnitPrimitive }

  subject(:catalog_loader) { described_class.new(model_class) }

  describe '#loader' do
    shared_examples 'returns expected loader class' do |expected_class|
      it "returns #{expected_class}" do
        expect(catalog_loader.loader).to be_an_instance_of(expected_class)
      end
    end

    context 'when ENV var is set to true' do
      before do
        stub_env('CLOUD_CONNECTOR_SELF_SIGN_TOKENS', '1')
      end

      include_examples 'returns expected loader class', ::Gitlab::CloudConnector::DataModel::YamlDataLoader
    end

    context 'when feature flag jh_enable_upload_cloud_license is enabled' do
      before do
        stub_feature_flags(jh_enable_upload_cloud_license: true)
      end

      include_examples 'returns expected loader class', ::Gitlab::CloudConnector::DataModel::YamlDataLoader
    end

    context 'when feature flag jh_enable_upload_cloud_license is disabled' do
      before do
        stub_feature_flags(jh_enable_upload_cloud_license: false)
      end

      it "returns DatabaseDataLoader" do
        allow(License).to receive(:current).and_return(License.new(cloud: false))

        expect(catalog_loader.loader).to be_an_instance_of(::CloudConnector::DatabaseDataLoader)
      end
    end
  end
end
