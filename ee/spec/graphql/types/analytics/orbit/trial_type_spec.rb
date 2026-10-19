# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Analytics::Orbit::TrialType, feature_category: :knowledge_graph do
  it { expect(described_class.graphql_name).to eq('OrbitTrial') }
  it { expect(described_class).to have_graphql_fields(:state, :expires_on, :credits, :offer) }
  it { expect(described_class).to require_graphql_authorizations(:read_orbit_trial) }
end
