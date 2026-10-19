# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Import::GiteeProviderRepoEntity do
  let(:repo_data) do
    instance_double(
      Gitee::Representation::Repo,
      full_name: 'namespace/repo',
      name: 'repo',
      clone_url: 'https://oauth2:abc123@gitee.com/namespace/repo.git'
    )
  end

  subject { described_class.new(repo_data).as_json }

  it_behaves_like 'exposes required fields for import entity' do
    let(:expected_values) do
      {
        id: 'namespace/repo',
        full_name: 'namespace/repo',
        sanitized_name: 'repo',
        provider_link: 'https://oauth2:abc123@gitee.com/namespace/repo.git'
      }
    end
  end
end
