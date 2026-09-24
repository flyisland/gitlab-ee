# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectFeature, feature_category: :groups_and_projects do
  using RSpec::Parameterized::TableSyntax

  describe 'default pages access level', :saas do
    subject(:pages_access_level) { project_feature.attributes['pages_access_level'] }

    let(:project_feature) do
      # project factory overrides all values in project_feature after creation
      project.project_feature.destroy!
      project.build_project_feature.save!
      project.project_feature
    end

    context 'when new project is private' do
      let(:project) { create(:project, :private) }

      it { is_expected.to eq(ProjectFeature::PRIVATE) }

      it 'return private when jh_hide_pages_access_level is false' do
        stub_feature_flags(jh_hide_pages_access_level: false)
        is_expected.to eq(ProjectFeature::PRIVATE)
      end
    end

    context 'when new project is internal' do
      let(:project) { create(:project, :internal) }

      it { is_expected.to eq(ProjectFeature::PRIVATE) }

      it 'return private when jh_hide_pages_access_level is false' do
        stub_feature_flags(jh_hide_pages_access_level: false)
        is_expected.to eq(ProjectFeature::PRIVATE)
      end
    end

    context 'when new project is public' do
      let(:project) { create(:project, :public) }

      it { is_expected.to eq(ProjectFeature::ENABLED) }

      it 'return internal when jh_hide_pages_access_level is false' do
        stub_feature_flags(jh_hide_pages_access_level: false)
        is_expected.to eq(ProjectFeature::ENABLED)
      end

      context 'when access control is forced on the admin level' do
        before do
          allow(::Gitlab::Pages).to receive(:access_control_is_forced?).and_return(true)
        end

        it { is_expected.to eq(ProjectFeature::PRIVATE) }

        it 'return enable when jh_hide_pages_access_level is false' do
          stub_feature_flags(jh_hide_pages_access_level: false)
          project_feature.update_column(:pages_access_level, ProjectFeature::ENABLED)

          is_expected.to eq(ProjectFeature::ENABLED)
        end
      end
    end
  end
end
