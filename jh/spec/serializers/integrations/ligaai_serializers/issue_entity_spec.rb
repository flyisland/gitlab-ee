# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::LigaaiSerializers::IssueEntity do
  let_it_be(:ligaai_integration) { create(:ligaai_integration) }
  let_it_be(:project) { ligaai_integration.project }

  let(:ligaai_issue) do
    {
      issueNumber: "CSXMR-7",
      dueDate: 1696154400000,
      description: "<p>作为一位开发人员，我想要在极狐GitLab的页面里实时同步看到LigaAI的工作项（需求，任务，缺陷）</p>",
      issueTypeId: 81272569,
      updateBy: 88211961,
      labelVO: [
        { color: "#333333", name: "api", id: 90942861, labelName: "api" },
        { color: "#333333", name: "tech", id: 90942868, labelName: "tech" }
      ],
      id: 88551213,
      summary: "Spike the integration between Gitlab and LigaAI",
      owner: 78455889,
      updateTime: 1682064795082,
      assigneeVO: {
        name: "liangp",
        departVOs: [],
        id: 78455889,
        avatar: "https://static.ligai.cn/pms/user_head/80999a33498b4797a394deaaa1495d4a.png",
        userType: 1,
        orgUserId: 78455897,
        accountEnabled: 1
      },
      createBy: 88211961,
      statusVO: {
        stateName: issue_status_name,
        name: issue_status_name,
        stateCategory: issue_status,
        id: 81272455
      },
      createTime: 1681453511365,
      createByVO: {
        name: "xfyuan",
        departVOs: [],
        id: 88211961,
        avatar: "https://static.ligai.cn/pms/user_head/9202f6cd011344e3a3a0dc4753a0f7e2.png",
        userType: 0,
        orgUserId: 88211962,
        accountEnabled: 1
      },
      assignee: 78455889,
      projectId: 81272373
    }.deep_stringify_keys
  end

  subject { described_class.new(ligaai_issue, project: project).as_json }

  context 'when status is "opened"' do
    let(:issue_status) { 3 }
    let(:issue_status_name) { 'opened' }

    it 'returns the LigaAI issues attributes' do
      expected_hash = common_expected_hash.merge(status: 'opened', state: 'opened')

      expect(subject).to include(expected_hash)
    end
  end

  context 'when status is "closed"' do
    let(:issue_status) { 4 }
    let(:issue_status_name) { 'closed' }

    it 'returns the LigaAI issues attributes' do
      expected_hash = common_expected_hash.merge(
        status: 'closed', state: 'closed', closed_at: '2023-04-21 08:13:15 UTC'.to_datetime)

      expect(subject).to include(expected_hash)
    end
  end

  private

  def common_expected_hash
    { id: 88551213,
      project_id: project.id,
      title: "Spike the integration between Gitlab and LigaAI",
      closed_at: nil,
      created_at: '2023-04-14 06:25:11 UTC'.to_datetime,
      updated_at: '2023-04-21 08:13:15 UTC'.to_datetime,
      due_date: '2023-10-01 10:00:00 UTC'.to_datetime,
      labels: [
        { id: 90942861, title: "api", name: "api", color: "#0052CC", text_color: "#FFFFFF" },
        { id: 90942868, title: "tech", name: "tech", color: "#0052CC", text_color: "#FFFFFF" }
      ],
      author:
      { id: 88211961,
        name: "xfyuan",
        web_url: "",
        avatar_url:
        "https://static.ligai.cn/pms/user_head/9202f6cd011344e3a3a0dc4753a0f7e2.png" },
      assignees: [
        { id: 78455889,
          name: "liangp",
          web_url: "",
          avatar_url:
          "https://static.ligai.cn/pms/user_head/80999a33498b4797a394deaaa1495d4a.png" }
      ],
      web_url: "",
      gitlab_web_url: "/#{project.full_path}/-/integrations/ligaai/issues/88551213" }
  end
end
