import { shallowMountExtended, mountExtended } from 'helpers/vue_test_utils_helper';
import AgentSessionsList from 'ee/ai/shared/widgets/agent_sessions_list.vue';
import AgentSessionRow from 'ee/ai/shared/widgets/agent_session_row.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';

const buildSession = (overrides = {}) => ({
  id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
  status: 'RUNNING',
  ...overrides,
});

describe('AgentSessionsList', () => {
  let wrapper;

  const createComponent = ({
    sessions = [],
    isLoading = false,
    mountFn = shallowMountExtended,
  } = {}) => {
    wrapper = mountFn(AgentSessionsList, {
      propsData: { sessions, isLoading },
      stubs: { AgentSessionRow: true },
    });
  };

  const findCrudComponent = () => wrapper.findComponent(CrudComponent);
  const findAllSessionRows = () => wrapper.findAllComponents(AgentSessionRow);
  const findCollapsedSection = () => wrapper.findByTestId('collapsed-sessions-section');
  const findToggleButton = () => wrapper.findByTestId('toggle-collapsed-sessions');

  describe('when loading', () => {
    it('renders no session rows', () => {
      createComponent({ isLoading: true, sessions: [buildSession()], mountFn: mountExtended });

      expect(findAllSessionRows()).toHaveLength(0);
    });
  });

  describe('with no sessions', () => {
    it('does not render the crud component', () => {
      createComponent({ sessions: [] });

      expect(findCrudComponent().exists()).toBe(false);
    });

    it('renders no session rows and no collapsed section', () => {
      createComponent({ sessions: [] });

      expect(findAllSessionRows()).toHaveLength(0);
      expect(findCollapsedSection().exists()).toBe(false);
    });
  });

  describe('with only active sessions', () => {
    it('renders the crud component expanded by default', () => {
      createComponent({
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'RUNNING' }),
        ],
      });

      expect(findCrudComponent().props('collapsed')).toBe(false);
    });

    it('renders a row for each active session and no collapsed section', () => {
      createComponent({
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'RUNNING' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'PAUSED' }),
        ],
      });

      expect(findAllSessionRows()).toHaveLength(2);
      expect(findCollapsedSection().exists()).toBe(false);
    });
  });

  describe('with mixed active and inactive sessions', () => {
    beforeEach(() => {
      createComponent({
        mountFn: mountExtended,
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'RUNNING' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'FINISHED' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/3', status: 'CREATED' }),
        ],
      });
    });

    it('only renders active session rows initially (inactive collapsed by default)', () => {
      expect(findAllSessionRows()).toHaveLength(1);
      expect(findAllSessionRows().at(0).props('session').status).toBe('RUNNING');
    });

    it('renders the collapsed sessions section', () => {
      expect(findCollapsedSection().exists()).toBe(true);
    });

    it('shows "Show {{ number }} of inactive sessions" toggle label initially', () => {
      expect(findToggleButton().text()).toBe('Show 2 inactive sessions');
    });

    describe('after clicking the toggle', () => {
      beforeEach(async () => {
        await findToggleButton().trigger('click');
      });

      it('shows all session rows', () => {
        expect(findAllSessionRows()).toHaveLength(3);
      });

      it('changes the toggle label to "Hide {{ number }} inactive sessions"', () => {
        expect(findToggleButton().text()).toBe('Hide 2 inactive sessions');
      });

      describe('after clicking the toggle again', () => {
        beforeEach(async () => {
          await findToggleButton().trigger('click');
        });

        it('hides the inactive session rows again', () => {
          expect(findAllSessionRows()).toHaveLength(1);
        });

        it('reverts the toggle label', () => {
          expect(findToggleButton().text()).toBe('Show 2 inactive sessions');
        });
      });
    });
  });

  describe('with only inactive sessions', () => {
    it('renders the crud component collapsed by default', () => {
      createComponent({
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'FINISHED' }),
        ],
      });

      expect(findCrudComponent().props('collapsed')).toBe(true);
    });

    it('renders no active rows but shows the collapsed section expanded by default', () => {
      createComponent({
        mountFn: mountExtended,
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'FINISHED' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'CREATED' }),
        ],
      });

      expect(findAllSessionRows()).toHaveLength(2);
      expect(findCollapsedSection().exists()).toBe(true);
    });

    it('shows "Hide {{ number }} inactive sessions" toggle label initially', () => {
      createComponent({
        mountFn: mountExtended,
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'FINISHED' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'CREATED' }),
        ],
      });

      expect(findToggleButton().text()).toBe('Hide 2 inactive sessions');
    });
  });

  describe('singular toggle label', () => {
    it('uses singular form for a single inactive session', async () => {
      createComponent({
        mountFn: mountExtended,
        sessions: [
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'RUNNING' }),
          buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'FINISHED' }),
        ],
      });

      expect(findToggleButton().text()).toBe('Show 1 inactive session');

      await findToggleButton().trigger('click');

      expect(findToggleButton().text()).toBe('Hide 1 inactive session');
    });
  });

  describe('session row props', () => {
    it('passes the session object to each AgentSessionRow', () => {
      const session = buildSession({ status: 'RUNNING' });
      createComponent({ sessions: [session] });

      expect(findAllSessionRows().at(0).props('session')).toEqual(session);
    });
  });
});
