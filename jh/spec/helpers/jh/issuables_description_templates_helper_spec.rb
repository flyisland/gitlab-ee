# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuablesDescriptionTemplatesHelper, :clean_gitlab_redis_cache do
  describe '#selected_template_name' do
    let(:template_names) { %w[main another_branch_template custom_branch_template] }

    it 'returns nil when feature flag is disabled' do
      stub_feature_flags(jh_mr_use_target_branch_description_template: false)
      allow(helper).to receive(:params).and_return({ merge_request: { target_branch: 'dev' } })

      expect(helper.selected_template_name(template_names)).to be_nil
    end

    context 'when an target_branch params has been provided' do
      before do
        allow(helper).to receive(:params).and_return({ merge_request: { target_branch: target_branch_name } })
      end

      context 'when target branch name matches existing templates' do
        let(:target_branch_name) { 'another_branch_template' }

        it 'returns the matching issuable template' do
          expect(helper.selected_template_name(template_names)).to eq('another_branch_template')
        end
      end

      context 'when target branch name does not match any templates' do
        let(:target_branch_name) { 'non_matching_branch_template' }

        it 'returns nil' do
          expect(helper.selected_template_name(template_names)).to be_nil
        end
      end
    end

    context 'when target_branch params has not been provided' do
      let_it_be(:project) { build(:project) }

      before do
        allow_any_instance_of(Project).to receive(:default_branch).and_return('main')
        allow(helper).to receive_messages(
          ref_project: project,
          params: { merge_request: { source_branch: 'demo-123' } }
        )
      end

      it 'returns the main template' do
        expect(helper.selected_template_name(template_names)).to eq('main')
      end
    end
  end
end
