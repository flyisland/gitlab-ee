# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::IntegrationsHelper do
  include Devise::Test::ControllerHelpers

  let(:controller_class) do
    helper_mod = described_class

    # rubocop:disable Rails/ApplicationController -- This is a helper class
    Class.new(ActionController::Base) do
      include helper_mod
      include ActionView::Helpers::AssetUrlHelper

      def slack_auth_project_settings_slack_url(_project)
        "http://some-path/project/1"
      end
    end
    # rubocop:enable Rails/ApplicationController
  end

  let_it_be_with_refind(:project) { create(:project) }

  subject { controller_class.new }

  describe '#ligaai_issue_breadcrumb_link' do
    subject { helper.ligaai_issue_breadcrumb_link(issue_json) }

    # rubocop:disable Layout/LineLength -- For long html string
    context 'with valid issue JSON' do
      let(:issue_json) { { id: "my-issue", url: "https://ligaai.cn" } }

      it 'returns the correct HTML' do
        is_expected.to eq('<img width="15" height="15" class="gl-mr-2 lazy" data-src="/images/logos/ligaai.svg" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" /><a target="_blank" rel="noopener noreferrer" class="gl-flex gl-items-center gl-whitespace-nowrap" href="https://ligaai.cn">my-issue</a>')
      end
    end

    context 'when issue_reference contains XSS' do
      let(:issue_json) { { id: "<script>alert('XSS')</script>my-issue", url: "javascript:alert('XSS')" } }

      it 'strips all tags and sanitizes' do
        is_expected.to eq('<img width="15" height="15" class="gl-mr-2 lazy" data-src="/images/logos/ligaai.svg" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" /><a target="_blank" rel="noopener noreferrer" class="gl-flex gl-items-center gl-whitespace-nowrap">my-issue</a>')
      end
    end
    # rubocop:enable Layout/LineLength
  end
end
