# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder, feature_category: :workflow_catalog do
  let_it_be(:default_organization) { create(:organization) }

  let(:wiki_definition) do
    described_class.new.agents.find { |agent| agent[:name] == 'Wiki Agent' }[:definition]
  end

  before do
    allow(::Organizations::Organization).to receive(:default_organization).and_return(default_organization)
  end

  it 'configures the Wiki Agent workload' do
    parsed_definition = YAML.safe_load(wiki_definition, permitted_classes: [], aliases: false)

    expect(parsed_definition).to include(
      'injectGatewayToken' => true,
      'image' => 'registry.jihulab.com/gitlab-cn/modelops/wiki-agent-image:latest',
      'commands' => [
        '. /opt/wiki-agent/agent_session_helper.sh',
        '/opt/wiki-agent/run.sh'
      ]
    )

    expect(parsed_definition).not_to have_key('variables')
  end

  describe '#seed_missing_agents!' do
    let(:seeder) { described_class.new }

    before do
      ['Claude Agent by GitLab', 'Codex Agent by GitLab'].each do |name|
        create(
          :ai_catalog_third_party_flow,
          :public,
          :with_released_version,
          organization: default_organization,
          name: name,
          verification_level: :gitlab_maintained
        )
      end
    end

    it 'adds the Wiki Agent to an instance that already seeded built-in agents' do
      expect { seeder.seed_missing_agents! }
        .to change { Ai::Catalog::Item.count }.by(1)
        .and change { Ai::Catalog::ItemVersion.count }.by(1)

      wiki_agent = Ai::Catalog::Item.find_by(name: 'Wiki Agent')

      expect(wiki_agent).to have_attributes(
        organization: default_organization,
        verification_level: 'gitlab_maintained',
        visibility: 'public',
        latest_released_version: wiki_agent.latest_version
      )
    end

    it 'is idempotent' do
      seeder.seed_missing_agents!

      expect { seeder.seed_missing_agents! }
        .to not_change { Ai::Catalog::Item.count }
        .and not_change { Ai::Catalog::ItemVersion.count }
    end
  end

  context 'when built-in external agents have never been seeded' do
    it 'does not seed only the JH additions' do
      expect { described_class.new.seed_missing_agents! }
        .to not_change { Ai::Catalog::Item.count }
        .and not_change { Ai::Catalog::ItemVersion.count }
    end
  end
end
