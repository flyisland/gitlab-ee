import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AskDapPermissions from 'ee/personal_access_tokens/components/create_granular_token/ask_dap_permissions.vue';
import OpenAgenticChatButton from 'ee/ai/shared/widgets/open_agentic_chat_button.vue';
import getAccessTokenPermissions from '~/personal_access_tokens/graphql/get_access_token_permissions.query.graphql';

Vue.use(VueApollo);

const mockPermissions = [
  {
    name: 'read_project',
    description: 'Grants the ability to read projects',
    action: 'read',
    category: 'groups_and_projects',
    categoryName: 'Groups and projects',
    resource: 'project',
    resourceName: 'Project',
    resourceDescription: 'Project resource description',
    boundaries: ['GROUP', 'PROJECT'],
  },
  {
    name: 'write_project',
    description: 'Grants the ability to write to projects',
    action: 'write',
    category: 'groups_and_projects',
    categoryName: 'Groups and projects',
    resource: 'project',
    resourceName: 'Project',
    resourceDescription: 'Project resource description',
    boundaries: ['GROUP', 'PROJECT'],
  },
];

const mockPermissionsResponse = { data: { accessTokenPermissions: mockPermissions } };

describe('AskDapPermissions', () => {
  let wrapper;
  let mockApollo;

  const mockQueryHandler = jest.fn().mockResolvedValue(mockPermissionsResponse);

  const createComponent = ({ queryHandler = mockQueryHandler, agenticAvailable = true } = {}) => {
    mockApollo = createMockApollo([[getAccessTokenPermissions, queryHandler]]);

    wrapper = shallowMountExtended(AskDapPermissions, {
      apolloProvider: mockApollo,
      provide: { agenticAvailable },
    });
  };

  beforeEach(() => {
    window.gon = { current_user_id: 42 };
    createComponent();
  });

  const findOpenWithAgent = () => wrapper.findComponent(OpenAgenticChatButton);

  describe('rendering', () => {
    it('renders the OpenAgenticChatButton component with correct props', () => {
      expect(findOpenWithAgent().exists()).toBe(true);
      expect(findOpenWithAgent().props('buttonText')).toBe('Add permissions with Duo');
      expect(findOpenWithAgent().props('resourceId')).toBe('gid://gitlab/User/42');
      expect(findOpenWithAgent().props('agent')).toEqual({ name: 'Permissions Assistant' });
      expect(findOpenWithAgent().props('welcomeMessage')).toContain(
        'fine-grained permissions assistant',
      );
      expect(findOpenWithAgent().props('predefinedPrompts')).toEqual(
        expect.arrayContaining([expect.any(String)]),
      );
    });

    it('does not render when agenticAvailable is false', () => {
      createComponent({ agenticAvailable: false });

      expect(findOpenWithAgent().exists()).toBe(false);
    });
  });

  describe('Apollo query', () => {
    it('fetches permissions on mount', async () => {
      await waitForPromises();

      expect(mockQueryHandler).toHaveBeenCalled();
    });

    it('disables the button while permissions are loading', () => {
      expect(findOpenWithAgent().props('buttonOptions')).toMatchObject({ disabled: true });
    });

    it('enables the button after permissions are loaded', async () => {
      await waitForPromises();

      expect(findOpenWithAgent().props('buttonOptions')).toMatchObject({ disabled: false });
    });

    describe('when the query fails', () => {
      beforeEach(() => {
        createComponent({ queryHandler: jest.fn().mockRejectedValue(new Error('network error')) });
      });

      it('disables the button', async () => {
        await waitForPromises();

        expect(findOpenWithAgent().props('buttonOptions')).toMatchObject({ disabled: true });
      });

      it('sets a title on the button options', async () => {
        await waitForPromises();

        expect(findOpenWithAgent().props('buttonOptions')).toMatchObject({
          title: 'Unable to load permissions',
        });
      });
    });
  });

  describe('handleToolCompleted()', () => {
    const callHandler = (name, args) => {
      findOpenWithAgent().vm.$emit('tool-completed', { name, args });
    };

    beforeEach(() => {
      wrapper.vm.permissions = mockPermissions;
    });

    it('emits permissions-selected for valid select args', () => {
      callHandler('update_form_permissions', { select: ['read_project'] });

      expect(wrapper.emitted('permissions-selected')[0]).toEqual([['read_project']]);
    });

    it('emits permissions-cleared for valid clear args', () => {
      callHandler('update_form_permissions', { clear: ['read_project'] });

      expect(wrapper.emitted('permissions-cleared')[0]).toEqual([['read_project']]);
    });

    it('handles both select and clear in the same event', () => {
      callHandler('update_form_permissions', {
        select: ['write_project'],
        clear: ['read_project'],
      });

      expect(wrapper.emitted('permissions-selected')[0]).toEqual([['write_project']]);
      expect(wrapper.emitted('permissions-cleared')[0]).toEqual([['read_project']]);
    });

    it('filters out invalid permission names', () => {
      callHandler('update_form_permissions', {
        select: ['read_project', 'not_a_valid_permission'],
      });

      expect(wrapper.emitted('permissions-selected')[0]).toEqual([['read_project']]);
    });

    it('does not emit when no valid permissions exist', () => {
      callHandler('update_form_permissions', { select: ['not_a_valid_permission'] });

      expect(wrapper.emitted('permissions-selected')).toBeUndefined();
    });

    it('ignores events for a different tool', () => {
      callHandler('some_other_tool', { select: ['read_project'] });

      expect(wrapper.emitted('permissions-selected')).toBeUndefined();
      expect(wrapper.emitted('permissions-cleared')).toBeUndefined();
    });

    it('ignores events with no args', () => {
      callHandler('update_form_permissions');

      expect(wrapper.emitted('permissions-selected')).toBeUndefined();
      expect(wrapper.emitted('permissions-cleared')).toBeUndefined();
    });
  });
});
