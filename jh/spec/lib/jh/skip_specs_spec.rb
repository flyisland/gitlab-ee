# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::SkipSpecs, feature_category: :development do
  let(:skip_specs) { described_class.new('unused.yml') }
  let(:file_path) { 'ee/spec/policies/global_policy_spec.rb' }
  let(:description_prefix) do
    'GlobalPolicy manage instance AI model configuration manage self-hosted DAP models ' \
      'when admin is_offline_license: true, is_dap_add_on_available: false, '
  end

  before do
    allow(skip_specs).to receive(:skipped_list).and_return(
      file_path => { 'description_prefix' => [description_prefix] }
    )
  end

  it 'skips examples whose descriptions match a configured prefix' do
    example = instance_double(
      RSpec::Core::Example,
      file_path: "./#{file_path}",
      full_description: "#{description_prefix}can_read_dap_models: #<RSpec::Matchers::BuiltIn::BePredicate>",
      metadata: {}
    )

    expect(skip_specs.skipped?(example)).to be(true)
  end

  it 'does not skip examples whose descriptions do not match a configured prefix' do
    example = instance_double(
      RSpec::Core::Example,
      file_path: "./#{file_path}",
      full_description: 'GlobalPolicy manage instance AI model configuration manage self-hosted DAP models ' \
        'when admin is_offline_license: false, is_dap_add_on_available: false, ',
      metadata: {}
    )

    expect(skip_specs.skipped?(example)).to be(false)
  end
end
