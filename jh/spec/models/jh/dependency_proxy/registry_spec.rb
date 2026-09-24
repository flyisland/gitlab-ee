# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::DependencyProxy::Registry, feature_category: :dependency_proxy do
  let(:tag)      { '2.3.5-alpine' }
  let(:blob_sha) { '40bd001563085fc35165329ea1ff5c5ecbdbbeef' }

  shared_examples 'handles manifest url' do |image|
    let(:img) { image.include?('/') ? image : "library/#{image}" }

    it 'returns a tencent mirror manifest url', :saas do
      expect(described_class.manifest_url(image, tag))
        .to eq("#{JH::DependencyProxy::Registry::LIBRARY_URL}/#{img}/manifests/2.3.5-alpine")
    end

    it 'returns a docker.io manifest url when feature flag disabled', :saas do
      stub_feature_flags(dependency_proxy_use_tencent_source: false)

      expect(described_class.manifest_url(image, tag))
        .to eq("https://registry-1.docker.io/v2/#{img}/manifests/2.3.5-alpine")
    end

    it 'returns a docker.io manifest url when not in Gitlab SASS' do
      expect(described_class.manifest_url(image, tag))
        .to eq("https://registry-1.docker.io/v2/#{img}/manifests/2.3.5-alpine")
    end
  end

  shared_examples 'handles blob url' do |image|
    let(:img) { image.include?('/') ? image : "library/#{image}" }

    it 'returns a tencent mirror blob url', :saas do
      expect(described_class.blob_url(image, blob_sha))
        .to eq("#{JH::DependencyProxy::Registry::LIBRARY_URL}/#{img}/blobs/40bd001563085fc35165329ea1ff5c5ecbdbbeef")
    end

    it 'returns a docker.io blob url when feature flag disabled', :saas do
      stub_feature_flags(dependency_proxy_use_tencent_source: false)

      expect(described_class.blob_url(image, blob_sha))
        .to eq("https://registry-1.docker.io/v2/#{img}/blobs/40bd001563085fc35165329ea1ff5c5ecbdbbeef")
    end

    it 'returns a docker.io blob url when not in Gitlab SASS' do
      expect(described_class.blob_url(image, blob_sha))
        .to eq("https://registry-1.docker.io/v2/#{img}/blobs/40bd001563085fc35165329ea1ff5c5ecbdbbeef")
    end
  end

  context 'when image name without namespace' do
    describe '#manifest_url' do
      it_behaves_like 'handles manifest url', 'ruby'
    end

    describe '#blob_url' do
      it_behaves_like 'handles blob url', 'ruby'
    end
  end

  context 'when image name with namespace' do
    describe '#manifest_url' do
      it_behaves_like 'handles manifest url', 'foo/ruby'
    end

    describe '#blob_url' do
      it_behaves_like 'handles blob url', 'foo/ruby'
    end
  end
end
