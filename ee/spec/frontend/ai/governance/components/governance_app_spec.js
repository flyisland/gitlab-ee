import { GlTabs } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import GovernanceApp from 'ee/ai/governance/components/governance_app.vue';
import AgentArtifactsApp from 'ee/agent_artifacts/components/agent_artifacts_app.vue';
import PageHeading from '~/vue_shared/components/page_heading.vue';

describe('GovernanceApp', () => {
  let wrapper;

  const createComponent = ({ glFeatures = {} } = {}) => {
    wrapper = shallowMountExtended(GovernanceApp, {
      provide: {
        glFeatures,
      },
    });
  };

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findToolManagementTab = () => wrapper.findByTestId('tool-management-tab');
  const findAgentArtifactsTab = () => wrapper.findByTestId('agent-artifacts-tab');

  describe('page heading', () => {
    it('renders the page heading', () => {
      createComponent();

      expect(findPageHeading().exists()).toBe(true);
      expect(findPageHeading().text()).toContain('Control how your AI-powered features are used.');
    });
  });

  describe('tabs', () => {
    it('renders the GlTabs component', () => {
      createComponent();

      expect(findTabs().exists()).toBe(true);
    });

    it('renders the Tool management tab', () => {
      createComponent();

      expect(findToolManagementTab().exists()).toBe(true);
    });
  });

  describe('when agentArtifactsPage feature flag is enabled', () => {
    beforeEach(() => {
      createComponent({ glFeatures: { agentArtifactsPage: true } });
    });

    it('renders the Agent artifacts tab', () => {
      expect(findAgentArtifactsTab().exists()).toBe(true);
    });

    it('renders AgentArtifactsApp when the Agent artifacts tab is active', async () => {
      await findTabs().vm.$emit('input', 1);
      await waitForPromises();

      expect(wrapper.findComponent(AgentArtifactsApp).exists()).toBe(true);
    });
  });

  describe('when agentArtifactsPage feature flag is disabled', () => {
    beforeEach(() => {
      createComponent({ glFeatures: { agentArtifactsPage: false } });
    });

    it('does not render the Agent artifacts tab', () => {
      expect(findAgentArtifactsTab().exists()).toBe(false);
    });
  });
});
