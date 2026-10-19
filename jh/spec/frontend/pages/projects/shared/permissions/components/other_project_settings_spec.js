import { nextTick } from 'vue';
import { mountExtended, extendedWrapper } from 'helpers/vue_test_utils_helper';
import OtherProjectSettings from 'jh/pages/projects/shared/permissions/components/other_project_settings.vue';
import { PRIVATE_VISIBILITY_LEVEL, PUBLIC_VISIBILITY_LEVEL } from 'jh/projects/new/constants';

const { gon } = window;

describe('Other project settings component', () => {
  let wrapper;
  const findTermsComponent = () => wrapper.findByTestId('project-setting-terms');

  const createComponent = (parentOptions) => {
    const parentComponent = {
      ...parentOptions,
      components: { OtherProjectSettings },
      template: '<div><other-project-settings /></div>',
    };

    wrapper = extendedWrapper(mountExtended(parentComponent).findComponent(OtherProjectSettings));
  };

  beforeEach(() => {
    window.gon = {
      ...gon,
      dot_com: true,
    };
  });

  afterEach(() => {
    window.gon = gon;
  });

  it('should show project terms when project is originally private and changed to public', async () => {
    createComponent({
      data() {
        return {
          visibilityLevel: PRIVATE_VISIBILITY_LEVEL,
        };
      },
    });
    expect(findTermsComponent().exists()).toBe(false);

    wrapper.vm.$parent.visibilityLevel = PUBLIC_VISIBILITY_LEVEL;
    await nextTick();

    expect(findTermsComponent().exists()).toBe(true);
  });

  it('should not show project terms when project is originally public', async () => {
    createComponent({
      data() {
        return {
          visibilityLevel: PUBLIC_VISIBILITY_LEVEL,
        };
      },
    });

    expect(findTermsComponent().exists()).toBe(false);

    wrapper.vm.$parent.visibilityLevel = PRIVATE_VISIBILITY_LEVEL;
    await nextTick();

    expect(findTermsComponent().exists()).toBe(false);
  });
});
