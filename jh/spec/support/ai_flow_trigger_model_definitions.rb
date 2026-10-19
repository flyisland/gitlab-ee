# frozen_string_literal: true

RSpec.configure do |config|
  config.before(rerun_file_path: %r{/ee/spec/services/ai/flow_triggers/run_service_spec\.rb\z}) do
    stub_request(:get, %r{/v1/models%2Fdefinitions\z})
      .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
  end
end
