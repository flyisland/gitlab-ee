# frozen_string_literal: true

RSpec.shared_examples 'renders ones basic issue fields' do
  it 'renders current values' do
    expect(entity[:id]).to eq("task-#{task_uuid}")
    expect(entity[:project_id]).to eq(integration.project.id)
    expect(entity[:title]).to eq(resource['name'])
    expect(entity[:web_url]).to eq(integration.url)
    expect(entity[:gitlab_web_url]).to eq(
      project_integrations_ones_issue_path(integration.project, "task-#{task_uuid}"))
  end
end
