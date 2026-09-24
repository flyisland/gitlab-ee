# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GiteeImport::ProjectCreator do
  let(:user) { create(:user) }

  let(:repo) do
    instance_double(
      Gitee::Representation::Repo,
      name: 'Vim',
      slug: 'vim',
      description: 'Test repo',
      owner: "asd",
      full_name: 'vim/repo',
      visibility_level: Gitlab::VisibilityLevel::PRIVATE,
      clone_url: 'http://gitee.com/asd/vim.git',
      has_wiki?: false
    )
  end

  let(:namespace) { create(:group) }
  let(:token) { "asdasd12345" }
  let(:access_params) { { gitee_access_token: token } }

  before do
    namespace.add_owner(user)
  end

  it 'creates project' do
    project_creator = described_class.new(repo, 'vim', namespace, user, access_params)
    project = project_creator.execute

    expect(project.import_url).to eq("http://gitee.com/asd/vim.git")
    expect(project.visibility_level).to eq(Gitlab::VisibilityLevel::PRIVATE)
  end
end
