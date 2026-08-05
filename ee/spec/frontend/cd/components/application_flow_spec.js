import { GlAlert, GlBadge, GlLoadingIcon } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ApplicationFlow from 'ee/cd/components/application_flow.vue';
import cdApplicationFlowQuery from 'ee/cd/graphql/cd_application_flow.query.graphql';

Vue.use(VueApollo);

describe('ApplicationFlow', () => {
  let wrapper;

  const applicationId = 'gid://gitlab/Cd::Application/7';
  const flowEditorRoute = { name: 'flow_editor_route', params: { id: '7' } };

  const flowV2 = {
    id: 'gid://gitlab/Cd::ApplicationFlowDefinition/2',
    version: 2,
    definition: 'trigger:\n  type: pipeline\n',
  };

  const buildResponse = (nodes = [flowV2]) => ({
    data: {
      organization: {
        id: 'gid://gitlab/Organizations::Organization/1',
        cdApplication: {
          id: applicationId,
          name: 'payments-platform',
          applicationFlowDefinitions: { nodes },
        },
      },
    },
  });

  const defaultHandler = jest.fn().mockResolvedValue(buildResponse());

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findBadge = () => wrapper.findComponent(GlBadge);
  const findEditButton = () => wrapper.findByTestId('edit-flow-button');
  const findCreateButton = () => wrapper.findByTestId('create-flow-button');
  const findDefinition = () => wrapper.findByTestId('flow-definition');

  const createComponent = ({ handler = defaultHandler } = {}) => {
    wrapper = shallowMountExtended(ApplicationFlow, {
      apolloProvider: createMockApollo([[cdApplicationFlowQuery, handler]]),
      propsData: { applicationId },
    });
  };

  describe('while loading', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });
  });

  describe('when the query errors', () => {
    beforeEach(async () => {
      createComponent({ handler: jest.fn().mockRejectedValue(new Error('boom')) });
      await waitForPromises();
    });

    it('renders the error alert', () => {
      expect(findAlert().props('variant')).toBe('danger');
      expect(findAlert().text()).toContain('Failed to load the application flow');
    });
  });

  describe('with no flow defined', () => {
    beforeEach(async () => {
      createComponent({ handler: jest.fn().mockResolvedValue(buildResponse([])) });
      await waitForPromises();
    });

    it('renders the empty state message', () => {
      expect(wrapper.text()).toContain('No flow is defined for this application yet.');
    });

    it('renders the create button linking to the flow editor', () => {
      expect(findCreateButton().props('to')).toEqual(flowEditorRoute);
    });

    it('does not render the definition or the version badge', () => {
      expect(findDefinition().exists()).toBe(false);
      expect(findBadge().exists()).toBe(false);
    });
  });

  describe('with a flow defined', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the latest version badge', () => {
      expect(findBadge().text()).toBe('Version 2');
    });

    it('renders the latest definition', () => {
      expect(findDefinition().text()).toContain('trigger:');
      expect(findDefinition().text()).toContain('type: pipeline');
    });

    it('renders the edit button linking to the flow editor', () => {
      expect(findEditButton().props('to')).toEqual(flowEditorRoute);
    });
  });
});
