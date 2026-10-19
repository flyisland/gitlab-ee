# frozen_string_literal: true

module QA
  module Resource
    class ProjectImportedFromGitee < Resource::Project
      attr_accessor :gitee_personal_access_token,
        :gitee_repository_path,
        :gitee_file

      def fabricate!
        self.import = true

        Page::Main::Menu.perform(&:go_to_create_project)

        go_to_import_page

        Page::Project::Import::Gitee.perform do |import_page|
          import_page.add_personal_access_token(gitee_personal_access_token)
          import_page.import!(gitee_repository_path, group.full_path, name)
          import_page.wait_for_success(gitee_repository_path, wait: 240)
        end

        reload!
        visit!
      end

      def go_to_import_page
        Page::Project::New.perform do |project_page|
          project_page.click_import_project
          project_page.click_gitee_link
        end
      end

      def fabricate_via_api!
        super
      rescue ResourceURLMissingError
        "#{Runtime::Scenario.gitlab_address}/#{full_path}"
      end

      def api_post_path
        '/import/gitee'
      end

      def api_contents_path
        "repos/#{gitee_repository_path}/contents/#{gitee_file}"
      end

      def transform_api_resource(api_resource)
        api_resource
      end

      def get_repo_contents
        Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 10) do
          response = get(gitee_api_request(api_contents_path).url)

          Runtime::Logger.info "Get contents request response: #{response}"

          unless response.code == Support::API::HTTP_STATUS_OK
            raise ResourceQueryError, "Could not get repo contents. Request returned (#{response.code}): `#{response}`."
          end

          process_api_response(parse_body(response))
        end
      end

      def update_repo_contents(body)
        Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 10) do
          response = put(gitee_api_request(api_contents_path).url, body)

          Runtime::Logger.info "Update contents request response: #{response}"
          response.code == Support::API::HTTP_STATUS_OK
        end
      end

      private

      def gitee_api_client
        @gitee_api_client ||= Runtime::API::Client.new(Runtime::Env.gitee_api_address,
          personal_access_token: Runtime::Env.gitee_access_token)
      end

      def gitee_api_request(path)
        Runtime::API::ThirdPartyRequest.new(gitee_api_client, path, access_token: Runtime::Env.gitee_access_token)
      end
    end
  end
end
