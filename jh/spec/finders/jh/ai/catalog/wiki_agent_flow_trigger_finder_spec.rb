# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Ai::Catalog::WikiAgentFlowTriggerFinder, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:service_account) { create(:service_account, provisioned_by_group: group) }

  subject(:result) { described_class.new(project).execute.first }

  def create_trigger(name:, verification_level: :gitlab_maintained, active: true, project: self.project)
    item = create(
      :ai_catalog_third_party_flow,
      :with_released_version,
      name: name,
      organization: project.organization,
      verification_level: verification_level,
      visibility: :public
    )
    parent_consumer = create(
      :ai_catalog_item_consumer,
      item: item,
      group: project.root_ancestor,
      service_account: service_account
    )
    consumer = create(
      :ai_catalog_item_consumer,
      item: item,
      project: project,
      parent_item_consumer: parent_consumer
    )

    create(
      :ai_flow_trigger,
      :for_catalog_consumer,
      project: project,
      ai_catalog_item_consumer: consumer,
      active: active
    )
  end

  it 'finds the active GitLab-maintained Wiki Agent trigger' do
    expected_trigger = create_trigger(name: described_class::AGENT_NAME)

    expect(result).to eq(expected_trigger)
  end

  it 'does not match another external agent' do
    create_trigger(name: 'Another external agent')

    expect(result).to be_nil
  end

  it 'does not match an inactive trigger' do
    create_trigger(name: described_class::AGENT_NAME, active: false)

    expect(result).to be_nil
  end

  it 'does not match a user-created agent with the same name' do
    create_trigger(name: described_class::AGENT_NAME, verification_level: :unverified)

    expect(result).to be_nil
  end
end
