import { shallowMount } from '@vue/test-utils';
import { GlSkeletonLoader, GlAvatarLink } from '@gitlab/ui';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
import { getUser } from '~/api/user_api';
import waitForPromises from 'helpers/wait_for_promises';
import { getBinding, createMockDirective } from 'helpers/vue_mock_directive';

jest.mock('~/api/user_api');

describe('AgentFlowTriggeredUser', () => {
  let wrapper;

  const mockUser = {
    username: 'testuser',
    name: 'Test User',
    web_url: 'https://gitlab.com/testuser',
  };

  const defaultProps = {
    isLoading: false,
    userId: 'gid://gitlab/User/123',
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(AgentFlowTriggeredUser, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
    });
  };

  const findSkeletonLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const findAvatarLink = () => wrapper.findComponent(GlAvatarLink);

  beforeEach(() => {
    getUser.mockResolvedValue({ data: mockUser });
  });

  describe('when loading', () => {
    beforeEach(() => {
      createWrapper({ isLoading: true });
    });

    it('renders skeleton loader', () => {
      expect(findSkeletonLoader().exists()).toBe(true);
    });

    it('does not render avatar link', () => {
      expect(findAvatarLink().exists()).toBe(false);
    });
  });

  describe('when loaded', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('does not render skeleton loader', () => {
      expect(findSkeletonLoader().exists()).toBe(false);
    });

    it('fetches user data with numeric ID', () => {
      expect(getUser).toHaveBeenCalledWith(123);
    });

    it('renders avatar link with correct props', () => {
      expect(findAvatarLink().attributes()).toEqual(
        expect.objectContaining({
          href: mockUser.web_url,
          'data-user-id': '123',
          'data-username': mockUser.username,
        }),
      );
    });

    it('renders username with @ symbol', () => {
      expect(wrapper.text()).toContain(`@${mockUser.username}`);
    });

    it('renders avatar link with tooltip', () => {
      const avatarLink = findAvatarLink();
      const tooltip = getBinding(avatarLink.element, 'gl-tooltip');

      expect(tooltip).toBeDefined();
      expect(tooltip.modifiers.bottom).toBe(true);
      expect(avatarLink.attributes('title')).toBe(mockUser.name);
    });
  });

  describe('with numeric userId', () => {
    beforeEach(async () => {
      createWrapper({ userId: '456' });
      await waitForPromises();
    });

    it('fetches user data with the numeric ID directly', () => {
      expect(getUser).toHaveBeenCalledWith('456');
    });
  });

  describe('without userId', () => {
    beforeEach(() => {
      createWrapper({ userId: '' });
    });

    it('does not fetch user data', () => {
      expect(getUser).not.toHaveBeenCalled();
    });
  });

  describe('when user fetch fails', () => {
    beforeEach(async () => {
      getUser.mockRejectedValue(new Error('Network error'));
      createWrapper();
      await waitForPromises();
    });

    it('renders component with empty user data', () => {
      expect(findAvatarLink().attributes()).toEqual(
        expect.objectContaining({
          href: '',
          'data-username': '',
        }),
      );
    });
  });

  describe('when userId changes', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
      jest.clearAllMocks();
    });

    it('fetches new user data', async () => {
      await wrapper.setProps({ userId: 'gid://gitlab/User/789' });
      await waitForPromises();

      expect(getUser).toHaveBeenCalledWith(789);
    });
  });
});
