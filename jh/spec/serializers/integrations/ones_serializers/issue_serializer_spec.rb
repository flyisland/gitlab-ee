# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::OnesSerializers::IssueSerializer do
  include Gitlab::Routing.url_helpers
  include OnesClientHelper

  let_it_be(:project) { create(:project, :private, has_external_issue_tracker: true) }
  let_it_be(:integration) { create(:ones_integration, project: project) }

  let(:task_uuid) { SecureRandom.hex(8) }
  let(:category) { nil }
  let(:resource) { issue_response(task_uuid: task_uuid, category: category).deep_stringify_keys }

  subject(:entity) { described_class.new.represent(resource, project: integration.project) }

  before do
    stub_licensed_features(ones_issues_integration: true)
  end

  it_behaves_like 'renders ones basic issue fields'

  describe 'status' do
    using RSpec::Parameterized::TableSyntax
    where(:category, :status) do
      'to_do'       | 'open'
      'in_progress' | 'open'
      'done'        | 'closed'
    end

    with_them do
      it 'renders current status' do
        expect(entity[:status]).to eq(status)
      end
    end
  end
end
