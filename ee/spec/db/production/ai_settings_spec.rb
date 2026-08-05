# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AI Settings', feature_category: :ai_abstraction_layer do
  subject(:load_file) { load Rails.root.join('ee/db/fixtures/production/041_create_ai_settings.rb') }

  it 'creates a single AI settings record' do
    load_file

    expect(Ai::Setting.count).to eq 1
  end

  it 'does not raise when the record already exists' do
    Ai::Setting.instance

    expect { load_file }.not_to raise_error
    expect(Ai::Setting.count).to eq 1
  end
end
