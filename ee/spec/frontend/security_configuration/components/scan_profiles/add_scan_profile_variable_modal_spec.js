import { nextTick } from 'vue';
import {
  GlModal,
  GlCollapsibleListbox,
  GlFormRadioGroup,
  GlFormInput,
  GlFormCheckbox,
} from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AddScanProfileVariableModal from 'ee/security_configuration/components/scan_profiles/add_scan_profile_variable_modal.vue';
import StringListTokenSelector from 'ee/security_configuration/components/scan_profiles/string_list_token_selector.vue';

describe('AddScanProfileVariableModal', () => {
  let wrapper;

  const variableDefinitions = {
    historicScan: {
      label: 'Historic scan',
      description: 'Scan the full Git history instead of only the current state.',
      valueType: 'boolean',
      envVar: 'SECRET_DETECTION_HISTORIC_SCAN',
    },
    logOptions: {
      label: 'Log options',
      description: 'Options passed to git log to control the commit range scanned.',
      valueType: 'string',
      placeholder: '--since=1.year.ago',
      envVar: 'SECRET_DETECTION_LOG_OPTIONS',
    },
    excludedPaths: {
      label: 'Paths to exclude',
      description: 'Paths left out of the scan.',
      valueType: 'stringList',
      placeholder: 'spec/**',
      envVar: 'SECRET_DETECTION_EXCLUDED_PATHS',
    },
    imageSuffix: {
      label: 'Image variant',
      description: 'Which build of the analyzer image to pull.',
      valueType: 'enum',
      options: [
        { value: '', text: 'Default' },
        { value: '-fips', text: 'FIPS' },
      ],
      envVar: 'SECRET_DETECTION_IMAGE_SUFFIX',
    },
  };

  const configurableTriggers = [
    { value: 'MERGE_REQUEST_PIPELINE', label: 'Merge Request Pipelines' },
    { value: 'DEFAULT_BRANCH_PIPELINE', label: 'Branch pipelines (default only)' },
  ];

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AddScanProfileVariableModal, {
      propsData: {
        visible: true,
        title: 'Add secret detection variable',
        variableDefinitions,
        existingSettings: [],
        configurableTriggers,
        ...props,
      },
      stubs: { GlModal },
    });
  };

  const findModal = () => wrapper.findComponent(GlModal);
  const findListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findRadioGroup = () => wrapper.findComponent(GlFormRadioGroup);
  const findInput = () => wrapper.findComponent(GlFormInput);
  const findTokenSelector = () => wrapper.findComponent(StringListTokenSelector);
  const findApplyToAllCheckbox = () => wrapper.findComponent(GlFormCheckbox);
  const findSharedRadioGroup = () => wrapper.findAllComponents(GlFormRadioGroup).at(0);
  const findPerTriggerSection = () => wrapper.findByTestId('scan-profile-variable-per-trigger');
  const findTriggerRadioGroups = () => findPerTriggerSection().findAllComponents(GlFormRadioGroup);
  const findTriggerTokenSelectors = () =>
    findPerTriggerSection().findAllComponents(StringListTokenSelector);

  const selectVariable = async (setting) => {
    findListbox().vm.$emit('select', setting);
    await nextTick();
  };

  it('renders the title passed in as a prop', () => {
    createComponent({ title: 'Add SAST variable' });

    expect(findModal().props('title')).toBe('Add SAST variable');
  });

  it('renders the variable picker with only variables not already configured', () => {
    createComponent({ existingSettings: ['historicScan'] });

    expect(findListbox().props('items')).toEqual([
      {
        value: 'logOptions',
        text: 'Log options',
        envVar: 'SECRET_DETECTION_LOG_OPTIONS',
        description: 'Options passed to git log to control the commit range scanned.',
      },
      {
        value: 'excludedPaths',
        text: 'Paths to exclude',
        envVar: 'SECRET_DETECTION_EXCLUDED_PATHS',
        description: 'Paths left out of the scan.',
      },
      {
        value: 'imageSuffix',
        text: 'Image variant',
        envVar: 'SECRET_DETECTION_IMAGE_SUFFIX',
        description: 'Which build of the analyzer image to pull.',
      },
    ]);
  });

  describe('empty variable list', () => {
    it('tells the user their search matched nothing, when variables are still available', () => {
      createComponent();

      findListbox().vm.$emit('search', 'no such variable');

      expect(findListbox().props('noResultsText')).toBe('No variables found.');
    });

    it('tells the user every variable has already been added, when none are left', () => {
      createComponent({
        existingSettings: ['historicScan', 'logOptions', 'excludedPaths', 'imageSuffix'],
      });

      expect(findListbox().props('items')).toEqual([]);
      expect(findListbox().props('noResultsText')).toBe(
        'All available variables have already been added.',
      );
    });
  });

  it('disables the primary action until a variable is picked', () => {
    createComponent();

    expect(findModal().props('actionPrimary').attributes.disabled).toBe(true);
  });

  it('does not show any value field before a variable is picked', () => {
    createComponent();

    expect(findRadioGroup().exists()).toBe(false);
    expect(findInput().exists()).toBe(false);
    expect(findTokenSelector().exists()).toBe(false);
  });

  describe('boolean variable', () => {
    beforeEach(async () => {
      createComponent();
      await selectVariable('historicScan');
    });

    it('renders an Enabled/Disabled radio group', () => {
      expect(findRadioGroup().props('options')).toEqual([
        { value: true, text: 'Enabled' },
        { value: false, text: 'Disabled' },
      ]);
    });

    it('enables the primary action once a value is picked', async () => {
      expect(findModal().props('actionPrimary').attributes.disabled).toBe(true);

      findRadioGroup().vm.$emit('input', false);
      await nextTick();

      expect(findModal().props('actionPrimary').attributes.disabled).toBe(false);
    });

    it('emits add with the shared value applied to every configurable trigger on save', async () => {
      findRadioGroup().vm.$emit('input', true);
      await nextTick();

      findModal().vm.$emit('primary');

      expect(wrapper.emitted('add')).toEqual([
        [
          {
            setting: 'historicScan',
            values: {
              MERGE_REQUEST_PIPELINE: true,
              DEFAULT_BRANCH_PIPELINE: true,
            },
          },
        ],
      ]);
    });
  });

  it('does not emit add when primary fires without a variable selected', () => {
    createComponent();

    findModal().vm.$emit('primary');

    expect(wrapper.emitted('add')).toBeUndefined();
  });

  describe('string variable', () => {
    it('renders a text input with the placeholder', async () => {
      createComponent();
      await selectVariable('logOptions');

      expect(findInput().props('placeholder')).toBe('--since=1.year.ago');
    });
  });

  describe('string list variable', () => {
    it('disables the primary action until a token is added', async () => {
      createComponent();
      await selectVariable('excludedPaths');

      expect(findTokenSelector().props('placeholder')).toBe('spec/**');
      expect(findModal().props('actionPrimary').attributes.disabled).toBe(true);

      findTokenSelector().vm.$emit('input', ['spec/**']);
      await nextTick();

      expect(findModal().props('actionPrimary').attributes.disabled).toBe(false);
    });

    it('emits the tokens for every trigger on save', async () => {
      createComponent();
      await selectVariable('excludedPaths');

      findTokenSelector().vm.$emit('input', ['spec/**', 'fixtures/**']);
      await nextTick();
      findModal().vm.$emit('primary');

      expect(wrapper.emitted('add')[0][0].values).toEqual({
        MERGE_REQUEST_PIPELINE: ['spec/**', 'fixtures/**'],
        DEFAULT_BRANCH_PIPELINE: ['spec/**', 'fixtures/**'],
      });
    });

    it('emits the triggers given tokens on save', async () => {
      createComponent();
      await selectVariable('excludedPaths');
      findApplyToAllCheckbox().vm.$emit('input', false);
      await nextTick();

      findTriggerTokenSelectors().at(0).vm.$emit('input', ['spec/**', 'fixtures/**']);
      await nextTick();
      findModal().vm.$emit('primary');

      expect(wrapper.emitted('add')[0][0].values).toEqual({
        MERGE_REQUEST_PIPELINE: ['spec/**', 'fixtures/**'],
      });
    });
  });

  describe('enum variable', () => {
    it('disables the primary action until an option is explicitly picked', async () => {
      createComponent();
      await selectVariable('imageSuffix');

      expect(findModal().props('actionPrimary').attributes.disabled).toBe(true);
    });

    it('treats the Default (empty string) option as a set value once explicitly picked', async () => {
      createComponent();
      await selectVariable('imageSuffix');

      findRadioGroup().vm.$emit('input', '');
      await nextTick();

      expect(findModal().props('actionPrimary').attributes.disabled).toBe(false);
    });

    it('emits add with the Default (empty string) value when saved', async () => {
      createComponent();
      await selectVariable('imageSuffix');

      findRadioGroup().vm.$emit('input', '');
      await nextTick();
      findModal().vm.$emit('primary');

      expect(wrapper.emitted('add')).toEqual([
        [
          {
            setting: 'imageSuffix',
            values: {
              MERGE_REQUEST_PIPELINE: '',
              DEFAULT_BRANCH_PIPELINE: '',
            },
          },
        ],
      ]);
    });

    it('treats a non-default option as a set value', async () => {
      createComponent();
      await selectVariable('imageSuffix');

      findRadioGroup().vm.$emit('input', '-fips');
      await nextTick();

      expect(findModal().props('actionPrimary').attributes.disabled).toBe(false);
    });
  });

  describe('apply to all enabled triggers', () => {
    it('shows the checkbox only when there is more than one configurable trigger', async () => {
      createComponent({ configurableTriggers: [configurableTriggers[0]] });
      await selectVariable('historicScan');

      expect(findApplyToAllCheckbox().exists()).toBe(false);
    });

    it('hides the Value by trigger section while checked, showing only the enabled shared field', async () => {
      createComponent();
      await selectVariable('historicScan');

      expect(findApplyToAllCheckbox().props('checked')).toBe(true);
      expect(wrapper.findByTestId('scan-profile-variable-per-trigger').exists()).toBe(false);
      expect(findSharedRadioGroup().exists()).toBe(true);
      expect(findSharedRadioGroup().props('disabled')).toBe(false);
    });

    it('shows the Value by trigger section and disables the shared field once unchecked, keeping the checkbox visible and unchecked', async () => {
      createComponent();
      await selectVariable('historicScan');

      findApplyToAllCheckbox().vm.$emit('input', false);
      await nextTick();

      expect(findApplyToAllCheckbox().exists()).toBe(true);
      expect(findApplyToAllCheckbox().props('checked')).toBe(false);
      expect(findSharedRadioGroup().props('disabled')).toBe(true);
      expect(wrapper.findByTestId('scan-profile-variable-per-trigger').exists()).toBe(true);
      expect(findTriggerRadioGroups()).toHaveLength(2);
    });

    it('hides the Value by trigger section again and re-enables the shared field when checked again', async () => {
      createComponent();
      await selectVariable('historicScan');

      findApplyToAllCheckbox().vm.$emit('input', false);
      await nextTick();
      findApplyToAllCheckbox().vm.$emit('input', true);
      await nextTick();

      expect(wrapper.findByTestId('scan-profile-variable-per-trigger').exists()).toBe(false);
      expect(findSharedRadioGroup().props('disabled')).toBe(false);
    });

    it('emits add with only the triggers that were given a value', async () => {
      createComponent();
      await selectVariable('historicScan');

      findApplyToAllCheckbox().vm.$emit('input', false);
      await nextTick();

      findTriggerRadioGroups().at(0).vm.$emit('input', true);
      await nextTick();

      findModal().vm.$emit('primary');

      expect(wrapper.emitted('add')).toEqual([
        [{ setting: 'historicScan', values: { MERGE_REQUEST_PIPELINE: true } }],
      ]);
    });
  });

  describe('closing the modal', () => {
    it.each(['cancel', 'esc', 'backdrop', 'headerclose'])(
      'resets and emits cancel when closed via %s',
      async (trigger) => {
        createComponent();
        await selectVariable('historicScan');

        findModal().vm.$emit('hide', { trigger });

        expect(wrapper.emitted('cancel')).toHaveLength(1);
      },
    );

    it('does not emit cancel when the modal closes after a save', async () => {
      createComponent();
      await selectVariable('historicScan');

      findModal().vm.$emit('primary');
      findModal().vm.$emit('hide', { trigger: 'ok' });

      expect(wrapper.emitted('cancel')).toBeUndefined();
    });
  });
});
