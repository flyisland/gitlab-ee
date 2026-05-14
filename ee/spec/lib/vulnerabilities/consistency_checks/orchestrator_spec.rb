# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::ConsistencyChecks::Orchestrator, feature_category: :vulnerability_management do
  let_it_be(:project) { build_stubbed(:project) }
  let_it_be(:consistency_checks) do
    [
      Vulnerabilities::ConsistencyChecks::HasVulnerabilitiesIsCorrectCheck
    ]
  end

  describe '#execute' do
    subject(:execute) { described_class.new(project).execute }

    it 'executes each consistency check on the project' do
      expect(consistency_checks).to all(receive(:enqueue).with(project))

      execute
    end
  end
end
