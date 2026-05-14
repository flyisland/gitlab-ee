# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Work item API parity', feature_category: :team_planning do
  it_behaves_like 'work item API field parity' do
    let(:extra_graphql_feature_exceptions) do
      Set.new(%w[
        ai_session
        custom_fields
        requirement_legacy
        status
        test_reports
        verification_status
        vulnerabilities
      ])
    end

    let(:extra_skipped_feature_comparison) do
      Set.new(%w[health_status])
    end
  end

  it_behaves_like 'work item API create parity' do
    let(:widget_exceptions) do
      Set.new(%w[crm_contacts_widget custom_fields_widget health_status_widget iteration_widget
        status_widget weight_widget])
    end
  end

  it_behaves_like 'work item API filter parity' do
    let(:filter_parity_wip) do
      %w[
        exclude_group_work_items
        exclude_projects
        timeframe
        custom_field
        requirement_legacy_widget
        status
        verification_status_widget
      ]
    end

    let(:not_filter_parity_wip) { %w[custom_field] }
    let(:or_filter_parity_wip) { %w[custom_field health_status_filter weight] }
  end
end
