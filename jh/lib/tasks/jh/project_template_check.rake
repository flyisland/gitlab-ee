# frozen_string_literal: true

JH_PROJECT_TEMPLATE_PREVIEW_API_PATH = "/groups/gitlab-cn%2Fproject-templates/projects"
JH_PROJECT_TEMPLATE_ISSUE_API_PATH = "/projects/gitlab-cn%2Fgitlab/issues"
JH_PROJECT_TEMPLATE_ISSUE_TITLE = "Global 更改了项目模板，需要在极狐更新"
JH_PROJECT_TEMPLATE_MAX_PREVIEW_PAGE = 10

namespace :jh do
  namespace :project_template_check do
    desc "Check the difference between global and jihulab"
    task run: %i[environment] do
      # Pipeline default environment is test, it will be enabled the webmock
      WebMock.allow_net_connect! if defined?(WebMock)

      check_config!
      next if changed_templates.empty?

      puts issue_description

      issue_url = get_jihulab_issue_url!
      if issue_url
        puts "Already exists the related issue: #{issue_url}, canceling creates the new one..."
        next
      end

      create_jihulab_issue!
      exit 1
    end

    private

    def check_config!
      raise "Blank env `JIHU_REPORTER_TOKEN`" if ENV["JIHU_REPORTER_TOKEN"].blank?
      raise "Blank env `JH_PROJECT_TEMPLATE_ASSIGNEE_IDS`" if ENV["JH_PROJECT_TEMPLATE_ASSIGNEE_IDS"].blank?
    end

    def changed_templates
      added_templates = current_templates - previewed_templates
      removed_templates = previewed_templates - current_templates

      [].tap do |templates|
        templates << "- Global 新增了：#{added_templates.join(', ')}" if added_templates.any?
        templates << "- Global 移除了：#{removed_templates.join(', ')}" if removed_templates.any?
      end
    end

    def issue_description
      @issue_description ||= <<~MESSAGE
        检测到 project template 有变动：
        #{changed_templates.join("\n")}

        请 `gitlab-cn/project-templates` 维护者参考以下链接更新组内的项目：
        - 仓库镜像文档：<#{::Gitlab.doc_url}/jh/user/project/repository/mirror/>
        - Global 相关组：<https://gitlab.com/gitlab-org/project-templates>, <https://gitlab.com/pages>
        - 极狐相关组：<#{::Gitlab.com_url}/gitlab-cn/project-templates>
      MESSAGE
    end

    def create_jihulab_issue!
      body = Gitlab::Json.dump(
        title: JH_PROJECT_TEMPLATE_ISSUE_TITLE,
        confidential: true,
        labels: "feature::enhancement",
        assignee_ids: ENV["JH_PROJECT_TEMPLATE_ASSIGNEE_IDS"].split(","),
        description: issue_description
      )
      res = Gitlab::HTTP.post("#{api_endpoint}#{JH_PROJECT_TEMPLATE_ISSUE_API_PATH}", body: body,
        headers: headers, allow_local_requests: true)
      process_response!(res)
    end

    def get_jihulab_issue_url!
      query = { state: "opened", search: JH_PROJECT_TEMPLATE_ISSUE_TITLE }
      res = Gitlab::HTTP.get("#{api_endpoint}#{JH_PROJECT_TEMPLATE_ISSUE_API_PATH}", query: query,
        headers: headers, allow_local_requests: true)
      process_response!(res)
      return if res.parsed_response.empty?

      res.parsed_response[0]["web_url"]
    end

    def process_response!(response)
      raise "code: #{response.code}, body: #{response.body}" unless response.success?
    end

    def api_endpoint
      @api_endpoint ||= ENV["JH_PROJECT_TEMPLATE_ENDPOINT"].presence || "#{::Gitlab.com_url}/api/v4"
    end

    def headers
      { "Content-Type" => "application/json", "PRIVATE-TOKEN" => ENV["JIHU_REPORTER_TOKEN"] }
    end

    def current_templates
      @current_templates ||= begin
        templates = [
          *Gitlab::ProjectTemplate.localized_templates_table,
          *Gitlab::ProjectTemplate.localized_ee_templates_table,
          *Gitlab::ProjectTemplate.localized_jh_templates_table,
          *Gitlab::SampleDataTemplate.localized_templates_table
        ]
        templates.map { |template| template.preview.split("/").last }
      end
    end

    def previewed_templates
      @previewed_templates ||= begin
        page = 1
        templates = []

        loop do
          response = Gitlab::HTTP.get("#{api_endpoint}#{JH_PROJECT_TEMPLATE_PREVIEW_API_PATH}", query: { page: page },
            headers: headers, allow_local_requests: true)
          process_response!(response)
          templates += response.parsed_response.pluck("path") # rubocop:disable CodeReuse/ActiveRecord -- we need it
          break if response.headers["x-next-page"].blank?

          page += 1
          break if page > JH_PROJECT_TEMPLATE_MAX_PREVIEW_PAGE # Detect loop bug
        end

        templates
      end
    end
  end
end
