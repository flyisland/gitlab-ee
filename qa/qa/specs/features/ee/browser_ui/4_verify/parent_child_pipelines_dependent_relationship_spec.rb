# frozen_string_literal: true

module QA
  # This test uses `needs:project` premium feature,
  # it can only be run against an EE instance with an active license
  RSpec.describe 'Verify', feature_category: :continuous_integration do
    describe 'Parent-child pipelines dependent relationship' do
      let!(:project) { create(:project, name: 'pipelines-dependent-relationship') }
      let!(:runner) do
        create(:project_runner, project: project, name: project.name, tags: [project.name])
      end

      before do
        Flow::Login.sign_in
      end

      after do
        runner.remove_via_api!
      end

      it(
        'parent pipelines passes if child passes',
        testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/358062'
      ) do
        add_ci_files(success_child_ci_file)
        project.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          expect(parent_pipeline).to have_child_pipeline
          expect(parent_pipeline).to have_passed
        end
      end

      it(
        'parent pipeline fails if child fails',
        testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/358063'
      ) do
        add_ci_files(fail_child_ci_file, expected_status: 'failed')
        project.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          expect(parent_pipeline).to have_child_pipeline
          expect(parent_pipeline).to have_failed
        end
      end

      private

      def success_child_ci_file
        {
          action: 'create',
          file_path: '.child-ci.yml',
          content: <<~YAML
            child_job:
              stage: test
              tags: ["#{project.name}"]
              needs:
                - project: #{project.path_with_namespace}
                  job: job1
                  ref: #{project.default_branch}
                  artifacts: true
              script:
                - cat output.txt
                - echo "Child job done!"

          YAML
        }
      end

      def fail_child_ci_file
        {
          action: 'create',
          file_path: '.child-ci.yml',
          content: <<~YAML
            child_job:
              stage: test
              tags: ["#{project.name}"]
              script: exit 1

          YAML
        }
      end

      def parent_ci_file
        {
          action: 'create',
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            stages:
              - build
              - test
              - deploy

            default:
              tags: ["#{project.name}"]

            job1:
              stage: build
              script: echo "build success" > output.txt
              artifacts:
                paths:
                  - output.txt

            job2:
              stage: test
              trigger:
                include: ".child-ci.yml"
                strategy: depend

            job3:
              stage: deploy
              script: echo "parent deploy done"

          YAML
        }
      end

      def add_ci_files(child_ci_file, expected_status: 'success')
        create(:commit, project: project, commit_message: 'Add parent and child pipelines CI files', actions: [
          child_ci_file, parent_ci_file
        ])

        wait_for_pipeline_to_complete(expected_status: expected_status)
      end

      def wait_for_pipeline_to_complete(expected_status: 'success')
        Flow::Pipeline.wait_for_pipeline_creation_via_api(project: project)
        Flow::Pipeline.wait_for_latest_pipeline_to_finish(project: project)

        expect(project.latest_pipeline[:status]).to eq(expected_status)
      end
    end
  end
end
