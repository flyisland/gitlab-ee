# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::SnippetInstanceProxy do
  let(:snippet) { create(:personal_snippet) }

  subject { described_class.new(snippet) }

  describe '#as_indexed_json' do
    it 'serializes snippet as hash' do
      expect(subject.as_indexed_json.with_indifferent_access).to include(
        id: snippet.id,
        title: snippet.title,
        description: snippet.description,
        created_at: snippet.created_at,
        updated_at: snippet.updated_at,
        project_id: snippet.project_id,
        author_id: snippet.author_id,
        visibility_level: snippet.visibility_level
      )
    end

    describe 'project access data' do
      let_it_be(:project) { create(:project, :internal, :snippets_private) }
      let_it_be(:project_snippet) { create(:project_snippet, :private, project: project) }

      let(:migration_finished) { true }

      before do
        allow(::Elastic::DataMigrationService).to receive(:migration_has_finished?).and_call_original
        allow(::Elastic::DataMigrationService).to receive(:migration_has_finished?)
          .with(:add_project_visibility_level_to_snippets).and_return(migration_finished)
      end

      it 'adds the project visibility and snippets access level to a project snippet' do
        expect(described_class.new(project_snippet).as_indexed_json).to include(
          'visibility_level' => Gitlab::VisibilityLevel::PRIVATE,
          'project_visibility_level' => Gitlab::VisibilityLevel::INTERNAL,
          'snippets_access_level' => ProjectFeature::PRIVATE,
          'schema_version' => described_class::SCHEMA_VERSION
        )
      end

      it 'adds neither field to a personal snippet' do
        expect(subject.as_indexed_json.keys).not_to include('project_visibility_level', 'snippets_access_level')
      end

      context 'when the mapping migration has not finished' do
        let(:migration_finished) { false }

        it 'adds neither field to a project snippet and keeps the previous schema version' do
          json = described_class.new(project_snippet).as_indexed_json

          expect(json.keys).not_to include('project_visibility_level', 'snippets_access_level')
          expect(json['schema_version']).to eq(described_class::PREVIOUS_SCHEMA_VERSION)
        end
      end
    end
  end
end
