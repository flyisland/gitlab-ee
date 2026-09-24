import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import WorkplanEmptyStateHeader from 'ee/work_items/components/ai_widget/workplan_empty_state_header.vue';
import ReviewWorkplanEmptyState from 'ee/work_items/components/ai_widget/review_workplan_empty_state.vue';
import GenerateWorkplanEmptyState from 'ee/work_items/components/ai_widget/generate_workplan_empty_state.vue';
import { eventHub, OPEN_AGENT_PLAN_PANEL, GENERATE_AGENT_PLAN } from 'ee/ai/events/panel';

const RESOURCE_ID = 'gid://gitlab/WorkItem/1';
const WORK_ITEM_WEB_URL = 'http://gdk.test/gitlab-org/gitlab/-/work_items/1';
const PROJECT_PATH = 'gitlab-org/gitlab';
const WORK_ITEM_IID = '1';
const WORK_ITEM_TYPE = 'Issue';

describe('WorkplanEmptyStateHeader', () => {
  let wrapper;

  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMountExtended(WorkplanEmptyStateHeader, {
      propsData: {
        resourceId: RESOURCE_ID,
        workItemWebUrl: WORK_ITEM_WEB_URL,
        projectPath: PROJECT_PATH,
        workItemIid: WORK_ITEM_IID,
        workItemType: WORK_ITEM_TYPE,
        isPanelOpen: false,
        ...props,
      },
    });
  };

  const findReviewState = () => wrapper.findComponent(ReviewWorkplanEmptyState);
  const findGenerateState = () => wrapper.findComponent(GenerateWorkplanEmptyState);

  describe('when no workplan exists', () => {
    beforeEach(() => {
      createComponent({ props: { hasExistingWorkplan: false } });
    });

    it('renders the generate state and not the review state', () => {
      expect(findGenerateState().exists()).toBe(true);
      expect(findReviewState().exists()).toBe(false);
    });

    it('passes the resource id to the generate state', () => {
      expect(findGenerateState().props('resourceId')).toBe(RESOURCE_ID);
    });

    it('passes the work item web url to the generate state', () => {
      expect(findGenerateState().props('workItemWebUrl')).toBe(WORK_ITEM_WEB_URL);
    });

    describe('when the generate state requests the workplan', () => {
      let generateSpy;

      beforeEach(() => {
        generateSpy = jest.fn();
        eventHub.$on(GENERATE_AGENT_PLAN, generateSpy);
        findGenerateState().vm.$emit('generate-workplan');
      });

      afterEach(() => {
        eventHub.$off(GENERATE_AGENT_PLAN, generateSpy);
      });

      it('requests workplan generation', () => {
        expect(generateSpy).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('when a workplan exists', () => {
    beforeEach(() => {
      createComponent({ props: { hasExistingWorkplan: true } });
    });

    it('renders the review state and not the generate state', () => {
      expect(findReviewState().exists()).toBe(true);
      expect(findGenerateState().exists()).toBe(false);
    });

    it('passes the correct props to the review state', () => {
      expect(findReviewState().props()).toMatchObject({
        projectPath: PROJECT_PATH,
        workItemIid: WORK_ITEM_IID,
        workItemType: WORK_ITEM_TYPE,
        workItemWebUrl: WORK_ITEM_WEB_URL,
        isPanelOpen: false,
      });
    });

    describe('when the review state requests to view the workplan', () => {
      let openPanelSpy;

      beforeEach(() => {
        openPanelSpy = jest.fn();
        eventHub.$on(OPEN_AGENT_PLAN_PANEL, openPanelSpy);
        findReviewState().vm.$emit('view-workplan');
      });

      afterEach(() => {
        eventHub.$off(OPEN_AGENT_PLAN_PANEL, openPanelSpy);
      });

      it('opens the agent plan panel', () => {
        expect(openPanelSpy).toHaveBeenCalledTimes(1);
      });
    });
  });
});
