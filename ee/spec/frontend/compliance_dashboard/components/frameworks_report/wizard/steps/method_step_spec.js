import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import MethodStep from 'ee/compliance_dashboard/components/frameworks_report/wizard/steps/method_step.vue';

describe('MethodStep', () => {
  let wrapper;

  const createComponent = ({ glFeatures = {} } = {}) => {
    wrapper = shallowMountExtended(MethodStep, {
      provide: {
        frameworkImportUrl: '/import',
        glFeatures,
      },
    });
  };

  const findBlankPanel = () => wrapper.findByTestId('method-blank_framework');
  const findTemplatePanel = () => wrapper.findByTestId('method-from_template');
  const findImportPanel = () => wrapper.findByTestId('method-import_framework');

  describe('with the templates feature flag disabled', () => {
    beforeEach(() => createComponent());

    it('renders the blank and import panels', () => {
      expect(findBlankPanel().exists()).toBe(true);
      expect(findImportPanel().exists()).toBe(true);
    });

    it('does not render the from-template panel', () => {
      expect(findTemplatePanel().exists()).toBe(false);
    });

    it('emits select-blank when the blank panel is clicked', async () => {
      await findBlankPanel().trigger('click');

      expect(wrapper.emitted('select-blank')).toEqual([[]]);
    });
  });

  describe('with the templates feature flag enabled', () => {
    beforeEach(() => createComponent({ glFeatures: { complianceFrameworkTemplates: true } }));

    it('renders the from-template panel between blank and import', () => {
      expect(findTemplatePanel().exists()).toBe(true);
    });

    it('emits select-template when the template panel is clicked', async () => {
      await findTemplatePanel().trigger('click');

      expect(wrapper.emitted('select-template')).toEqual([[]]);
    });
  });
});
