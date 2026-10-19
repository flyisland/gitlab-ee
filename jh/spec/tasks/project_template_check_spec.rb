# frozen_string_literal: true

require "spec_helper"

RSpec.describe "project_template_check", :silence_stdout do
  let(:previewed_templates) { %w[previewed_template] }
  let(:previewed_templates_response) { previewed_templates.map { |template| { "path" => template } } }
  let(:current_templates) { %w[current_template] }
  let(:current_templates_response) do
    current_templates.map { |template| instance_double(Gitlab::ProjectTemplate, preview: template) }
  end

  before do
    Rake.application.rake_require("tasks/jh/project_template_check")

    stub_env("JH_PROJECT_TEMPLATE_ENDPOINT", "https://stub-api-endpoint.com/api/v4")
    stub_env("JIHU_REPORTER_TOKEN", "jihu_reporter_token")
    stub_env("JH_PROJECT_TEMPLATE_ASSIGNEE_IDS", "maintainer_id1,maintainer_id2")
    allow(Gitlab::ProjectTemplate).to receive(:all).and_return(current_templates_response)
    stub_request(:get, %r{^https://stub-api-endpoint.com/api/v4/groups/gitlab-cn%2Fproject-templates/projects})
      .to_return(
        {
          body: Gitlab::Json.dump(previewed_templates_response),
          headers: { "Content-Type" => "application/json", "x-next-page" => "2" }
        },
        {
          body: Gitlab::Json.dump(previewed_templates_response),
          headers: { "Content-Type" => "application/json" }
        }
      )
    stub_request(:get, %r{^https://stub-api-endpoint.com/api/v4/projects/gitlab-cn%2Fgitlab/issues})
      .to_return(
        body: "[]",
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:post, %r{^https://stub-api-endpoint.com/api/v4/projects/gitlab-cn%2Fgitlab/issues})
      .to_return(
        status: 200
      )
  end

  subject { run_rake_task("jh:project_template_check:run") }

  context "when check for differences" do
    it "output changed message" do
      expect { subject }.to output(/检测到 project template 有变动/).to_stdout
                        .and raise_error(SystemExit)
    end
  end

  context "when empty `JH_PROJECT_TEMPLATE_ASSIGNEE_IDS`" do
    before do
      stub_env("JH_PROJECT_TEMPLATE_ASSIGNEE_IDS", nil)
    end

    it "raise argument error" do
      expect { subject }.to raise_error(RuntimeError, /JH_PROJECT_TEMPLATE_ASSIGNEE_IDS/)
    end
  end

  context "when empty `JIHU_REPORTER_TOKEN`" do
    before do
      stub_env("JIHU_REPORTER_TOKEN", nil)
    end

    it "raise argument error" do
      expect { subject }.to raise_error(RuntimeError, /JIHU_REPORTER_TOKEN/)
    end
  end

  context "when there exist jihu related issue" do
    before do
      stub_request(:get, %r{^https://stub-api-endpoint.com/api/v4/projects/gitlab-cn%2Fgitlab/issues})
        .to_return(
          body: Gitlab::Json.dump([{ web_url: "stub_web_url" }]),
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "raise already issue error" do
      expect { subject }.to output(/Already exists the related issue: stub_web_url/).to_stdout
    end
  end

  context "when create jihu issue failed" do
    before do
      stub_request(:post, %r{^https://stub-api-endpoint.com/api/v4/projects/gitlab-cn%2Fgitlab/issues})
        .to_return(
          status: 400,
          body: "stub body"
        )
    end

    it "raise create issue http failed error" do
      expect { subject }.to raise_error(RuntimeError, /code: 400, body: stub body/)
    end
  end
end
