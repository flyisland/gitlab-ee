import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ImproveCiOnboardingPage from 'ee/ai/duo_agents_platform/pages/onboarding/improve_ci_onboarding_page.vue';
import OnboardingAction from 'ee/ai/duo_agents_platform/pages/onboarding/components/onboarding_action.vue';

describe('ImproveCiOnboardingPage', () => {
  let wrapper;

  const createWrapper = ({ hasGitlabCiYml = false } = {}) => {
    gon.has_gitlab_ci_yml = hasGitlabCiYml;

    wrapper = shallowMountExtended(ImproveCiOnboardingPage, {
      mocks: {
        $router: { resolve: jest.fn() },
      },
    });
  };

  const findOnboardingAction = () => wrapper.findComponent(OnboardingAction);
  const findNoGitlabCiYmlAlert = () => wrapper.findByTestId('no-gitlab-ci-yml-alert');

  it('renders OnboardingAction with correct props', () => {
    createWrapper({ hasGitlabCiYml: true });
    expect(findOnboardingAction().props()).toMatchObject({
      gonPathKey: 'improve_ci_path',
      buttonLabel: 'Improve CI setup',
      actionDisabled: false,
    });
  });

  describe('when .gitlab-ci.yml does not exist', () => {
    beforeEach(() => {
      createWrapper({ hasGitlabCiYml: false });
    });

    it('passes actionDisabled=true to OnboardingAction', () => {
      expect(findOnboardingAction().props('actionDisabled')).toBe(true);
    });

    it('shows the no-gitlab-ci-yml alert', () => {
      expect(findNoGitlabCiYmlAlert().exists()).toBe(true);
    });
  });

  describe('when .gitlab-ci.yml exists', () => {
    beforeEach(() => {
      createWrapper({ hasGitlabCiYml: true });
    });

    it('passes actionDisabled=false to OnboardingAction', () => {
      expect(findOnboardingAction().props('actionDisabled')).toBe(false);
    });

    it('does not show the no-gitlab-ci-yml alert', () => {
      expect(findNoGitlabCiYmlAlert().exists()).toBe(false);
    });
  });
});
