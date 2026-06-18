import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';

import { GlModal, GlSprintf } from '@gitlab/ui';

import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

import ClearProjectSettingsModal from 'ee/product_analytics/onboarding/components/providers/clear_project_settings_modal.vue';
import { TEST_PROJECT_FULL_PATH } from '../../../mock_data';

Vue.use(VueApollo);

jest.mock('~/sentry/sentry_browser_wrapper');

describe('ClearProjectSettingsModal', () => {
  /** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
  let wrapper;
  let mockApollo;

  const mockMutate = jest.fn();

  const findModal = () => wrapper.findComponent(GlModal);

  const createWrapper = (props = {}, provide = {}) => {
    mockApollo = createMockApollo([]);

    wrapper = shallowMountExtended(ClearProjectSettingsModal, {
      apolloProvider: mockApollo,
      propsData: {
        visible: true,
        ...props,
      },
      provide: {
        analyticsSettingsPath: `/${TEST_PROJECT_FULL_PATH}/-/settings/analytics`,
        namespaceFullPath: TEST_PROJECT_FULL_PATH,
        ...provide,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  describe('default behaviour', () => {
    beforeEach(() => createWrapper());

    it('should render modal', () => {
      expect(findModal().props('visible')).toBe(true);
    });
  });

  describe('when cancelling', () => {
    beforeEach(() => {
      createWrapper();
      findModal().vm.$emit('canceled');
      return nextTick();
    });

    it('should emit "hide" event', () => {
      expect(wrapper.emitted('hide')).toHaveLength(1);
    });

    it('should not modify project settings', () => {
      expect(mockMutate).not.toHaveBeenCalled();
    });
  });
});
