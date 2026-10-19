# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ContentSecurityPolicy::ConfigLoader, feature_category: :shared do
  let(:policy) { ActionDispatch::ContentSecurityPolicy.new }
  let(:lfs_enabled) { false }
  let(:proxy_download) { false }

  let(:csp_config) do
    {
      enabled: true,
      report_only: false,
      directives: {
        connect_src: "'self' ws://example.com"
      }
    }
  end

  let(:lfs_config) do
    {
      enabled: lfs_enabled,
      remote_directory: 'lfs-objects',
      connection: object_store_connection_config,
      direct_upload: false,
      proxy_download: proxy_download,
      storage_options: {}
    }
  end

  let(:object_store_connection_config) do
    {
      provider: 'AWS',
      aws_access_key_id: 'AWS_ACCESS_KEY_ID',
      aws_secret_access_key: 'AWS_SECRET_ACCESS_KEY'
    }
  end

  before do
    stub_lfs_setting(enabled: lfs_enabled)
    allow(LfsObjectUploader)
      .to receive(:object_store_options)
      .and_return(Gitlab::Configs::Options.build(lfs_config))
  end

  describe '.default_directives' do
    let(:directives) { described_class.default_directives }
    let(:connect_src) { directives['connect_src'] }

    before do
      stub_env('GITLAB_ANALYTICS_URL', nil)
    end

    context 'when sentry is configured' do
      let(:dsn) { 'dummy://def@sentry.example.com/2' }

      before do
        stub_config_setting(host: 'gitlab.example.com')
      end

      context 'when sentry is configured' do
        before do
          allow(Gitlab::CurrentSettings).to receive_messages(sentry_enabled: true, sentry_clientside_dsn: dsn)
        end

        it 'adds new sentry path to CSP' do
          expect(connect_src).to include("dummy://sentry.example.com")
        end
      end
    end
  end
end
