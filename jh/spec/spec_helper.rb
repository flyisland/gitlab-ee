# frozen_string_literal: true

require Rails.root.join("spec/support/helpers/stub_requests.rb")

# JH support helpers has been loaded, see: jh/config/initializers/require_jh_spec_support_helpers.rb
Dir[Rails.root.join("jh/spec/support/helpers/**/*.rb")].each { |f| require f }

Dir[Rails.root.join("jh/spec/support/shared_contexts/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("jh/spec/support/shared_examples/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("jh/spec/support/**/*.rb")].each { |f| require f }

require_relative '../lib/jh/skip_specs'

config_path = File.expand_path("config/skip_specs.yml", __dir__)
skip_specs = JH::SkipSpecs.new(config_path)

RSpec.configure do |config|
  # Set up license metadata similar to EE spec_helper
  config.define_derived_metadata(file_path: %r{jh/spec/}) do |metadata|
    metadata[:with_license] = metadata.fetch(:with_license, true)
  end

  config.before do |example|
    # We use the tag `phone_verification_code_enabled` to enable phone verification code in tests.
    # Add it to your test if you want to enable the phone verification code feature.
    # For example: describe '...', :phone_verification_code_enabled do
    # But we do not mock application_settings on test that use tag `do_not_mock_admin_mode_setting`
    if example.metadata[:phone_verification_code_enabled]
      stub_application_setting(phone_verification_code_enabled: true)
    end

    if example.metadata[:hk_saas]
      allow(Gitlab).to receive(:com?).and_return(true)
      stub_env('SAAS_REGION', 'HK')
    end

    # Set default value of `JH_AI_PROVIDER`
    stub_env('JH_AI_PROVIDER', example.metadata[:ai_provider].presence || :open_ai)

    # Set to false to avoid affecting Upstream's tests
    stub_feature_flags(ff_invitation_email_rate_limit: false)
    stub_feature_flags(jh_only_block_seat_for_team_plan: false)
    stub_feature_flags(jh_filter_countries: false)
    stub_feature_flags(jh_disable_subject_to_high_limit: false)
    stub_feature_flags(jh_enable_upload_cloud_license: false)
    stub_feature_flags(jh_disable_billing: false)
    # TODO: The root cause is unknown, but an error occurs when launching FF to execute Gitaly::Server.gitaly_clusters.
    # https://jihulab.com/gitlab-cn/gitlab/-/jobs/23775035
    stub_feature_flags(jh_block_free_ha: false)

    # Default enable ones_issues_integration to avoid upstream integration test failed
    stub_licensed_features(
      ones_issues_integration: true,
      native_secrets_management: true
    )

    # Setup i18n without JH locale po files for upstream specs and restore them for JH specs.
    # The upstream team often forgets to apply i18n during testing, which causes test failures due to the text content
    # covered by JH. Like https://jihulab.com/gitlab-cn/gitlab/-/jobs/23851094
    # Use rerun_file_path so shared examples follow the including spec instead of the shared example definition.
    setup_i18n_repositories(
      include_jh_locale_po: example.metadata[:rerun_file_path].start_with?('./jh')
    )

    # Gitlab::HTTP rewrites CDot hosts to 8.8.8.9 (DNS rebind protection), so
    # match by path rather than hostname. See StubRequests::IP_ADDRESS_STUB.
    WebMock.stub_request(:head, %r{/api/v1/consumers/resolve})
      .to_return(status: 200, body: "", headers: {})

    WebMock.stub_request(:get, %r{/api/v1/billing/usage/trials})
      .to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })

    WebMock.stub_request(:get, %r{/api/v1/consumers/resolve})
      .to_return(status: 200, body: "", headers: {})
  end

  if skip_specs.skipped_list.any?
    config.around do |example|
      Timeout.timeout(300) { example.run } unless skip_specs.skipped?(example)
    end
  end
end

def setup_i18n_repositories(include_jh_locale_po:, domain: 'gitlab')
  # Base on: Gitlab::I18n.setup_repositories
  locale_paths = ['locale']
  locale_paths.unshift('jh/locale') if include_jh_locale_po

  translation_repositories = locale_paths.map do |path|
    FastGettext::TranslationRepository.build(
      domain,
      path: Rails.root.join(path),
      type: :po,
      ignore_fuzzy: true
    )
  end

  FastGettext.add_text_domain(
    domain,
    type: :chain,
    chain: translation_repositories,
    ignore_fuzzy: true
  )

  FastGettext.default_text_domain = domain
end
