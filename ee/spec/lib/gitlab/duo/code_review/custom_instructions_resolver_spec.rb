# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Duo::CodeReview::CustomInstructionsResolver, feature_category: :code_suggestions do
  let(:group) { build_stubbed(:group) }
  let(:subgroup) { build_stubbed(:group, parent: group) }
  let(:project) do
    build_stubbed(
      :project, :with_code_review_custom_instructions,
      group: subgroup,
      instructions: project_instructions
    )
  end

  let(:resolver) { described_class.new(project) }
  let(:ref) { '1234-feature-implementation' }
  let(:ancestor_duo_template_projects) { [] }

  let(:group_instructions) do
    <<~YAML
      instructions:
        - name: "Group instructions"
          instructions: "Group instructions description"
          fileFilters:
            - "**/*.ts"
    YAML
  end

  let(:subgroup_instructions) do
    <<~YAML
      instructions:
        - name: "Subgroup instructions"
          instructions: "Subgroup instructions description"
          fileFilters:
            - "docs/**/*.md"
            - "!docs/build/**/*.md"
    YAML
  end

  let(:project_instructions) do
    <<~YAML
      instructions:
        - name: "Project instructions"
          instructions: "Project instructions description"
          fileFilters:
            - "app/models/**/*.rb"
            - "!app/models/concerns/**/*.rb"
    YAML
  end

  let(:diff_files) do
    [
      instance_double(Gitlab::Diff::File, file_path: 'app/models/user.rb'),
      instance_double(Gitlab::Diff::File, file_path: 'docs/architecture.md'),
      instance_double(Gitlab::Diff::File, file_path: 'app/frontend/user.ts')
    ]
  end

  let(:diffs) do
    instance_double(Gitlab::Diff::FileCollection::Base, diff_files: diff_files)
  end

  let(:merge_request) do
    instance_double(MergeRequest, diffs: diffs, target_branch_sha: ref)
  end

  before do
    allow(resolver).to receive(:ancestor_duo_template_projects)
      .and_return(ancestor_duo_template_projects)
  end

  describe '#execute' do
    subject(:instructions) { resolver.execute(merge_request) }

    context 'with an empty merge request' do
      let(:diff_files) { [] }

      it 'returns empty without hitting the repository' do
        expect(project.repository).not_to receive(:blob_at)
        expect(instructions).to be_empty
      end
    end

    context 'with no custom instructions file' do
      let(:project_instructions) { nil }

      it 'returns empty' do
        expect(instructions).to be_empty
      end
    end

    context 'with empty custom instructions file' do
      let(:project_instructions) { '' }

      it 'returns empty' do
        expect(instructions).to be_empty
      end
    end

    context 'with project custom instructions only' do
      it 'returns the project instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Project instructions')
        )
      end
    end

    context 'with group custom instructions only' do
      let(:project_instructions) { nil }
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:ancestor_duo_template_projects) do
        [group_duo_project_template]
      end

      it 'returns the group instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Group instructions')
        )
      end
    end

    context 'with both group and project custom instructions' do
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:ancestor_duo_template_projects) do
        [group_duo_project_template]
      end

      it 'returns both group and project instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Group instructions'),
          have_attributes(name: 'Project instructions')
        )
      end
    end

    context 'with multilevel group custom instructions' do
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:subgroup_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: subgroup,
          instructions: subgroup_instructions
        )
      end

      let(:ancestor_duo_template_projects) do
        [
          group_duo_project_template,
          subgroup_duo_project_template
        ]
      end

      it 'returns all groups and project instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Group instructions'),
          have_attributes(name: 'Subgroup instructions'),
          have_attributes(name: 'Project instructions')
        )
      end
    end

    context 'with multilevel group custom instructions and duplicated template projects' do
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:ancestor_duo_template_projects) do
        [
          group_duo_project_template,
          group_duo_project_template
        ]
      end

      it 'excludes duplicated instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Group instructions'),
          have_attributes(name: 'Project instructions')
        )
      end
    end

    context 'with malformed instructions' do
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: 'invalid YAML format'
        )
      end

      let(:ancestor_duo_template_projects) do
        [
          group_duo_project_template
        ]
      end

      it 'ignores malformed instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Project instructions')
        )
      end

      it 'tracks errors for malformed instructions' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception)
          .with(
            Exception,
            project_id: project.id,
            duo_template_project_id: group_duo_project_template.id
          )
          .once

        instructions
      end
    end

    context 'when some instructions are filtered out by file filters' do
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:ancestor_duo_template_projects) do
        [
          group_duo_project_template
        ]
      end

      let(:diff_files) do
        [
          instance_double(Gitlab::Diff::File, file_path: 'app/models/user.rb'), # included by project
          instance_double(Gitlab::Diff::File, file_path: 'docs/build/architecture.md') # excluded by group
        ]
      end

      it 'excludes filtered instructions' do
        expect(instructions).to contain_exactly(
          have_attributes(name: 'Project instructions')
        )
      end
    end

    context 'when some files are excluded by content exclusion' do
      let(:file_exclusion_service) { instance_double(Ai::FileExclusionService) }
      let(:group_duo_project_template) do
        build_stubbed(
          :project, :with_code_review_custom_instructions,
          group: group,
          instructions: group_instructions
        )
      end

      let(:ancestor_duo_template_projects) { [group_duo_project_template] }

      before do
        allow(Ai::FileExclusionService).to receive(:new).with(project).and_return(file_exclusion_service)
      end

      context 'when the file exclusion service returns an error' do
        before do
          allow(file_exclusion_service).to receive(:execute)
            .and_return(ServiceResponse.error(message: 'Something went wrong'))
        end

        it 'returns all matching instructions' do
          expect(instructions).to contain_exactly(
            have_attributes(name: 'Group instructions'),
            have_attributes(name: 'Project instructions')
          )
        end
      end

      context 'when a file matched by one instruction is excluded' do
        # app/frontend/user.ts matches group instructions (**/*.ts)
        # app/models/user.rb matches project instructions (app/models/**/*.rb)
        # excluding app/models/user.rb removes the only file that triggers project instructions
        before do
          allow(file_exclusion_service).to receive(:execute)
            .and_return(ServiceResponse.success(payload: [
              { path: 'app/models/user.rb', excluded: true },
              { path: 'docs/architecture.md', excluded: false },
              { path: 'app/frontend/user.ts', excluded: false }
            ]))
        end

        it 'excludes instructions that only match content-excluded files' do
          expect(instructions).to contain_exactly(
            have_attributes(name: 'Group instructions')
          )
        end
      end
    end
  end
end
