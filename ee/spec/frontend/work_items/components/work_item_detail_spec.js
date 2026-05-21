import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { isLoggedIn } from '~/lib/utils/common_utils';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { stubComponent } from 'helpers/stub_component';
import WorkItemDetailEE from 'ee/work_items/components/work_item_detail.vue';
import WorkItemDetailCE from '~/work_items/components/work_item_detail.vue';
import workItemByIidQuery from '~/work_items/graphql/work_item_by_iid.query.graphql';
import workItemUpdatedSubscription from '~/work_items/graphql/work_item_updated.subscription.graphql';
import workspacePermissionsQuery from '~/work_items/graphql/workspace_permissions.query.graphql';
import getAllowedWorkItemChildTypes from '~/work_items/graphql/work_item_allowed_children.query.graphql';
import DuoWorkflowAction from 'ee_component/ai/shared/widgets/duo_workflow_action.vue';
import AgentPlan from 'ee/work_items/components/agent_plan/agent_plan.vue';

import {
  workItemByIidResponseFactory,
  workItemResponseFactory,
  mockProjectPermissionsQueryResponse,
  allowedChildrenTypesResponse,
} from 'ee_else_ce_jest/work_items/mock_data';

jest.mock('~/lib/utils/common_utils');

describe('EE WorkItemDetail component', () => {
  let wrapper;

  Vue.use(VueApollo);

  const workItemByIidQueryResponse = workItemByIidResponseFactory({
    canUpdate: true,
    canDelete: true,
  });
  const successHandler = jest.fn().mockResolvedValue(workItemByIidQueryResponse);
  const workItemUpdatedSubscriptionHandler = jest
    .fn()
    .mockResolvedValue({ data: { workItemUpdated: null } });
  const workspacePermissionsAllowedHandler = jest
    .fn()
    .mockResolvedValue(mockProjectPermissionsQueryResponse());
  const allowedChildrenTypesHandler = jest.fn().mockResolvedValue(allowedChildrenTypesResponse);

  const createComponent = ({
    component = WorkItemDetailCE,
    workItemIid = '1',
    handler = successHandler,
    glFeatures = {},
    provide = {},
    workItem = null,
  } = {}) => {
    wrapper = shallowMountExtended(component, {
      apolloProvider: createMockApollo([
        [workItemByIidQuery, handler],
        [workItemUpdatedSubscription, workItemUpdatedSubscriptionHandler],
        [getAllowedWorkItemChildTypes, allowedChildrenTypesHandler],
        [workspacePermissionsQuery, workspacePermissionsAllowedHandler],
      ]),
      isLoggedIn: isLoggedIn(),
      propsData: {
        workItemIid,
        workItemFullPath: 'group/project',
      },
      provide: {
        glFeatures: {
          ...glFeatures,
        },
        duoRemoteFlowsAvailability: true,
        hasSubepicsFeature: true,
        hasLinkedItemsEpicsFeature: true,
        fullPath: 'group/project',
        groupPath: 'group',
        reportAbusePath: '/report/abuse/path',
        isGroup: true,
        ...provide,
      },
      mocks: {
        $router: true,
      },
      stubs: {
        WorkItemDetail: stubComponent(WorkItemDetailCE, {
          template: `<div><slot name="widgets" :work-item="workItem" /></div>`,
          data() {
            return { workItem };
          },
        }),
        WorkItemVulnerabilities: true,
        DuoWorkflowAction: true,
        AgentPlan: stubComponent(AgentPlan),
      },
    });
  };

  beforeEach(() => {
    isLoggedIn.mockReturnValue(true);
  });

  const findCeComponent = () => wrapper.findComponent(WorkItemDetailCE);
  const findVulnerabilitiesWidget = () =>
    wrapper.findComponentByTestId('work-item-vulnerabilities');
  const findDuoWorkflowAction = () => wrapper.findComponent(DuoWorkflowAction);
  const findAgentPlan = () => wrapper.findComponent(AgentPlan);

  describe('vulnerabilities widget', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('shows vulnerabilities widget', () => {
      expect(findVulnerabilitiesWidget().exists()).toBe(true);
    });
  });

  describe('Duo Workflow Action', () => {
    describe('when duoRemoteFlowsAvailability  is false', () => {
      beforeEach(async () => {
        createComponent({
          provide: { duoRemoteFlowsAvailability: false },
        });
        await waitForPromises();
      });

      it('does not show the DuoWorkflowAction component', () => {
        expect(findDuoWorkflowAction().exists()).toBe(false);
      });
    });

    describe('when duoRemoteFlowsAvailability is true', () => {
      beforeEach(async () => {
        window.gon = { current_username: 'testuser' };
        createComponent({
          provide: { duoRemoteFlowsAvailability: true },
        });
        await waitForPromises();
      });

      it('shows DuoWorkflowAction component', () => {
        expect(findDuoWorkflowAction().exists()).toBe(true);
      });

      it('passes correct props to DuoWorkflowAction', () => {
        const duoWorkflowAction = findDuoWorkflowAction();
        const { workItem } = workItemByIidQueryResponse.data.namespace;

        expect(duoWorkflowAction.props()).toMatchObject({
          projectPath: 'group/project',
          hoverMessage: 'Generate merge request with Duo',
          goal: expect.stringContaining(
            `@testuser assigned you to solve the following task: ${workItem.webUrl}`,
          ),
          workflowDefinition: 'developer/v1',
          agentPrivileges: [1, 2, 3, 4, 5],
          size: 'medium',
          workItemId: workItem.iid,
        });
        expect(duoWorkflowAction.text()).toBe('Generate MR with Duo');
      });
    });
  });

  describe('AgentPlan', () => {
    const agentPlanWidget = { __typename: 'WorkItemWidgetAgentPlan', type: 'AGENT_PLAN' };

    const createWorkItemWithAgentPlanWidget = (options = {}) => {
      const {
        data: { workItem },
      } = workItemResponseFactory(options);
      workItem.widgets.push(agentPlanWidget);
      return workItem;
    };

    describe('CE component rendering', () => {
      it('renders the CE WorkItemDetail component', () => {
        createComponent({ component: WorkItemDetailEE });

        expect(findCeComponent().exists()).toBe(true);
      });
    });

    describe('when agent plan is not available', () => {
      it.each`
        description                                                      | glFeatures                                          | workItem            | isAsync
        ${'agentPlan feature flag is disabled'}                          | ${{ agentPlan: false }}                             | ${undefined}        | ${true}
        ${'workItemFeaturesField enabled but agentPlan feature missing'} | ${{ agentPlan: true, workItemFeaturesField: true }} | ${{ features: {} }} | ${false}
        ${'agentPlan widget is not available'}                           | ${{ agentPlan: true }}                              | ${undefined}        | ${true}
      `('does not render when $description', async ({ glFeatures, workItem, isAsync }) => {
        createComponent({ component: WorkItemDetailEE, glFeatures, workItem });
        if (isAsync) await waitForPromises();

        expect(findAgentPlan().exists()).toBe(false);
      });
    });

    describe('when agent plan is available', () => {
      it.each`
        description                                                        | glFeatures                                          | workItem
        ${'workItemFeaturesField enabled and agentPlan feature available'} | ${{ agentPlan: true, workItemFeaturesField: true }} | ${{ features: { agentPlan: true } }}
        ${'workItemFeaturesField disabled but agentPlan widget present'}   | ${{ agentPlan: true }}                              | ${{ widgets: [{ __typename: 'WorkItemWidgetAgentPlan', type: 'AGENT_PLAN' }] }}
      `('renders when $description', ({ glFeatures, workItem }) => {
        createComponent({ component: WorkItemDetailEE, glFeatures, workItem });

        expect(findAgentPlan().exists()).toBe(true);
      });

      it('passes workItemId from workItem', () => {
        const workItem = createWorkItemWithAgentPlanWidget();
        createComponent({
          component: WorkItemDetailEE,
          glFeatures: { agentPlan: true },
          workItem,
        });

        expect(findAgentPlan().props('workItemId')).toBe(workItem.id);
      });

      it('passes canUpdate from workItem permissions', () => {
        const workItem = createWorkItemWithAgentPlanWidget({ canUpdate: true });
        createComponent({
          component: WorkItemDetailEE,
          glFeatures: { agentPlan: true },
          workItem,
        });

        expect(findAgentPlan().props('canUpdate')).toBe(true);
      });

      it('passes canUpdate as false when user cannot update', () => {
        const workItem = createWorkItemWithAgentPlanWidget({ canUpdate: false });
        createComponent({
          component: WorkItemDetailEE,
          glFeatures: { agentPlan: true },
          workItem,
        });

        expect(findAgentPlan().props('canUpdate')).toBe(false);
      });
    });
  });
});
