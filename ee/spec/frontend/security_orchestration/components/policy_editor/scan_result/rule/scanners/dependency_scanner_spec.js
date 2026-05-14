import { nextTick } from 'vue';
import { GlCollapse } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import DependencyScanner from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scanners/dependency_scanner.vue';
import ScannerHeader from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scanners/scanner_header.vue';
import ExploitSettingsSection from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scanners/exploit_settings_section.vue';
import EnrichmentDataSettings from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scan_filters/enrichment_data_settings.vue';
import AttributeFilters from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scan_filters/attribute_filters.vue';
import ScanFilterSelector from 'ee/security_orchestration/components/policy_editor/scan_filter_selector.vue';
import VulnerabilitiesAllowedSection from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scanners/vulnerabilities_allowed_section.vue';
import {
  FIX_AVAILABLE,
  FALSE_POSITIVE,
  KNOWN_EXPLOITED,
  EPSS_SCORE,
  ATTRIBUTE,
  ENRICHMENT_DATA_UNAVAILABLE,
  ENRICHMENT_DATA_ACTIONS,
} from 'ee/security_orchestration/components/policy_editor/scan_result/rule/scan_filters/constants';
import { GREATER_THAN_OPERATOR } from 'ee/security_orchestration/components/policy_editor/constants';
import { DEFAULT_EPSS_VALUE } from 'ee/security_orchestration/components/policy_editor/scan_result/lib/rules';

describe('DependencyScanner', () => {
  let wrapper;

  const defaultRule = {
    type: 'scan_finding',
    branches: [],
    scanners: ['dependency_scanning'],
    vulnerabilities_allowed: 0,
    severity_levels: [],
    vulnerability_states: [],
  };

  const createComponent = (scanner = defaultRule, options = {}) => {
    wrapper = shallowMountExtended(DependencyScanner, {
      propsData: {
        scanner,
        ...options,
      },
    });
  };

  const findCollapse = () => wrapper.findComponent(GlCollapse);
  const findScannerHeader = () => wrapper.findComponent(ScannerHeader);
  const findExploitSettingsSection = () => wrapper.findComponent(ExploitSettingsSection);
  const findEnrichmentDataSettings = () => wrapper.findComponent(EnrichmentDataSettings);
  const findAttributeFilters = () => wrapper.findComponent(AttributeFilters);
  const findFilterSelector = () => wrapper.findComponent(ScanFilterSelector);
  const findVulnerabilitiesAllowedSection = () =>
    wrapper.findComponent(VulnerabilitiesAllowedSection);

  describe('rendering', () => {
    it('renders all components correctly', () => {
      createComponent();

      expect(findCollapse().exists()).toBe(true);
      expect(findScannerHeader().exists()).toBe(true);
      expect(findExploitSettingsSection().exists()).toBe(true);
      expect(findEnrichmentDataSettings().exists()).toBe(true);
      expect(findAttributeFilters().exists()).toBe(true);
      expect(findFilterSelector().exists()).toBe(true);
    });
  });

  describe('EPSS value handling', () => {
    it('preserves EPSS value of 0 when setVulnerabilityAttributes runs', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: 'greater_than', value: 0 },
          [FIX_AVAILABLE]: true,
        },
      });

      findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted[EPSS_SCORE]).toEqual({ operator: 'greater_than', value: 0 });
    });

    it('injects default EPSS attribute when EPSS is not explicitly configured', () => {
      // By design, dependency_scanning scanners always include EPSS defaults.
      // When editing attributes on a scanner without explicit EPSS, the default
      // EPSS value is included in the emitted data.
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [FIX_AVAILABLE]: true,
        },
      });

      findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted).toHaveProperty(KNOWN_EXPLOITED);
      expect(emitted).toHaveProperty(EPSS_SCORE, {
        operator: GREATER_THAN_OPERATOR,
        value: DEFAULT_EPSS_VALUE,
      });
    });
  });

  describe('visibility prop', () => {
    it('is visible by default', () => {
      createComponent();

      expect(wrapper.props('visible')).toBe(true);
    });

    it('can be initialized as hidden', () => {
      createComponent(defaultRule, { visible: false });

      expect(wrapper.props('visible')).toBe(false);
    });
  });

  describe('default exploit settings', () => {
    beforeEach(() => {
      createComponent();
    });

    it('defaults KEV filter to true when not provided', () => {
      expect(findExploitSettingsSection().props('kevFilterValue')).toBe(true);
    });

    it('defaults EPSS operator to greater_than when not provided', () => {
      expect(findExploitSettingsSection().props('epssOperator')).toBe(GREATER_THAN_OPERATOR);
    });

    it('defaults EPSS value when not provided', () => {
      expect(findExploitSettingsSection().props('epssValue')).toBe(DEFAULT_EPSS_VALUE);
    });

    it('preserves EPSS value of 0 instead of falling back to default', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0 },
        },
      });

      expect(findExploitSettingsSection().props('epssValue')).toBe(0);
    });
  });

  describe('default attribute filters', () => {
    it('shows both attribute filters by default when no attributes provided', () => {
      createComponent();

      expect(findAttributeFilters().exists()).toBe(true);
      expect(findAttributeFilters().props('selected')).toEqual({
        [FIX_AVAILABLE]: true,
        [FALSE_POSITIVE]: false,
      });
    });
  });

  describe('phantom defaults do not leak into emitted policy data', () => {
    it('does not inject phantom attributes when removing a default attribute from a scanner with only KEV/EPSS', () => {
      // Scanner has KEV and EPSS but no explicit fix_available/false_positive.
      // The UI shows defaults via SCANNER_DEFAULT_ATTRIBUTES — removing one
      // must NOT inject the other as a new attribute into the emitted data.
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0.5 },
        },
      });

      findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      // Should preserve KEV and EPSS, include the remaining default (false_positive),
      // but NOT inject fix_available since the user explicitly removed it
      expect(emitted).toHaveProperty(KNOWN_EXPLOITED);
      expect(emitted).toHaveProperty(EPSS_SCORE);
      expect(emitted).toHaveProperty(FALSE_POSITIVE);
      expect(emitted).not.toHaveProperty(FIX_AVAILABLE);
    });

    it('preserves EPSS value of 0 when setVulnerabilityAttributes runs', () => {
      // EPSS value 0 is valid ("flag all vulnerabilities"). It must not be
      // silently dropped by a falsy check in setVulnerabilityAttributes.
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0 },
          [FIX_AVAILABLE]: true,
        },
      });

      // Trigger setVulnerabilityAttributes via removing an attribute filter
      findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted[EPSS_SCORE]).toEqual({ operator: GREATER_THAN_OPERATOR, value: 0 });
    });
  });

  describe('KEV and EPSS defaults are injected into emitted data on attribute edit', () => {
    it('includes default KEV and EPSS attributes when editing a scanner without explicit vulnerability_attributes', () => {
      // By design, dependency_scanning scanners always include KEV and EPSS defaults.
      // When the user edits any attribute (e.g. adds fix_available), the emitted data
      // should also contain the default KEV and EPSS values.
      createComponent();

      findFilterSelector().vm.$emit('select');

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted).toHaveProperty(KNOWN_EXPLOITED, true);
      expect(emitted).toHaveProperty(EPSS_SCORE, {
        operator: GREATER_THAN_OPERATOR,
        value: DEFAULT_EPSS_VALUE,
      });
    });
  });

  describe('existing rule', () => {
    const ruleWithValues = {
      ...defaultRule,
      vulnerabilities_allowed: 5,
      branch_exceptions: ['main'],
      vulnerability_attributes: {
        [KNOWN_EXPLOITED]: true,
        [EPSS_SCORE]: { operator: 'greater_than', value: 0.5 },
        [FIX_AVAILABLE]: true,
      },
    };

    beforeEach(() => {
      createComponent(ruleWithValues);
    });

    it('passes KEV filter value to exploit settings section', () => {
      expect(findExploitSettingsSection().props('kevFilterValue')).toBe(true);
    });

    it('passes EPSS filter values to exploit settings section', () => {
      expect(findExploitSettingsSection().props('epssOperator')).toBe('greater_than');
      expect(findExploitSettingsSection().props('epssValue')).toBe(0.5);
    });

    it('renders attribute filters when attributes are selected', () => {
      expect(findAttributeFilters().exists()).toBe(true);
      expect(findAttributeFilters().props('selected')).toEqual({
        [FIX_AVAILABLE]: true,
      });
    });
  });

  describe('events', () => {
    beforeEach(() => {
      createComponent();
    });

    it('emits changed event when KEV filter changes', () => {
      findExploitSettingsSection().vm.$emit('kev-change', true);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      expect(wrapper.emitted('changed')[0][0]).toHaveProperty('vulnerability_attributes');
      expect(wrapper.emitted('changed')[0][0].vulnerability_attributes).toHaveProperty(
        KNOWN_EXPLOITED,
        true,
      );
    });

    it('emits changed event when EPSS filter changes', () => {
      const epssValue = { operator: 'less_than', value: 0.3 };

      findExploitSettingsSection().vm.$emit('epss-change', epssValue);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      expect(wrapper.emitted('changed')[0][0]).toHaveProperty('vulnerability_attributes');
      expect(wrapper.emitted('changed')[0][0].vulnerability_attributes).toHaveProperty(
        EPSS_SCORE,
        epssValue,
      );
    });

    describe('attribute filters', () => {
      beforeEach(() => {
        createComponent({
          ...defaultRule,
          vulnerability_attributes: {
            [FIX_AVAILABLE]: true,
          },
        });
      });

      it('emits changed event when attribute filters change', () => {
        const payload = { [FIX_AVAILABLE]: true, [FALSE_POSITIVE]: false };

        findAttributeFilters().vm.$emit('input', payload);

        expect(wrapper.emitted('changed')).toHaveLength(1);
        expect(wrapper.emitted('changed')[0][0]).toHaveProperty('vulnerability_attributes');
      });

      it('removes attribute filter but preserves KEV/EPSS/enrichment defaults', () => {
        findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

        expect(wrapper.emitted('changed')).toHaveLength(1);
        expect(wrapper.emitted('changed')[0][0]).toHaveProperty('vulnerability_attributes');
        expect(wrapper.emitted('changed')[0][0].vulnerability_attributes).toEqual({
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: DEFAULT_EPSS_VALUE },
          [ENRICHMENT_DATA_UNAVAILABLE]: { action: ENRICHMENT_DATA_ACTIONS.BLOCK },
        });
      });
    });
  });

  describe('selecting filter', () => {
    it('adds the opposite attribute when one is already selected', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [FIX_AVAILABLE]: true,
        },
      });

      findFilterSelector().vm.$emit('select');

      expect(wrapper.emitted('changed')).toHaveLength(1);
      expect(wrapper.emitted('changed')[0][0].vulnerability_attributes).toHaveProperty(
        FALSE_POSITIVE,
        true,
      );
    });
  });

  describe('filter selector disabled state', () => {
    it('is disabled by default with both attributes selected', () => {
      createComponent();

      expect(findFilterSelector().props('shouldDisableFilter')(ATTRIBUTE)).toBe(true);
    });

    it('is not disabled when one attribute is selected', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [FIX_AVAILABLE]: true,
        },
      });

      expect(findFilterSelector().props('shouldDisableFilter')(ATTRIBUTE)).toBe(false);
    });

    it('is disabled when both attributes are explicitly selected', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [FIX_AVAILABLE]: true,
          [FALSE_POSITIVE]: false,
        },
      });

      expect(findFilterSelector().props('shouldDisableFilter')(ATTRIBUTE)).toBe(true);
    });
  });

  describe('scan filter selector', () => {
    it('passes correct filter state with default attributes', () => {
      createComponent();

      expect(findFilterSelector().props('selected')).toEqual({
        [FIX_AVAILABLE]: true,
        [FALSE_POSITIVE]: true,
        [ATTRIBUTE]: true,
      });
    });

    it('passes correct filter state when one attribute is selected', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [FIX_AVAILABLE]: true,
        },
      });

      expect(findFilterSelector().props('selected')).toEqual({
        [FIX_AVAILABLE]: true,
        [FALSE_POSITIVE]: false,
        [ATTRIBUTE]: false,
      });
    });

    it('passes correct filter state when both attributes are selected', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [FIX_AVAILABLE]: true,
          [FALSE_POSITIVE]: false,
        },
      });

      expect(findFilterSelector().props('selected')).toEqual({
        [FIX_AVAILABLE]: true,
        [FALSE_POSITIVE]: true,
        [ATTRIBUTE]: true,
      });
    });
  });

  describe('collapse behavior', () => {
    it('toggles collapse when header emits toggle', async () => {
      createComponent();

      expect(findCollapse().props('visible')).toBe(true);

      findScannerHeader().vm.$emit('toggle');
      await nextTick();

      expect(findCollapse().props('visible')).toBe(false);
    });
  });

  describe('vulnerabilities allowed section', () => {
    it('renders VulnerabilitiesAllowedSection component', () => {
      createComponent();

      expect(findVulnerabilitiesAllowedSection().exists()).toBe(true);
    });

    it('passes correct vulnerabilitiesAllowed value from scanner prop', () => {
      createComponent({ ...defaultRule, vulnerabilities_allowed: 5 });

      expect(findVulnerabilitiesAllowedSection().props('vulnerabilitiesAllowed')).toBe(5);
    });

    it('emits changed with updated vulnerabilities_allowed when input changes', () => {
      createComponent();

      findVulnerabilitiesAllowedSection().vm.$emit('input', 3);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      expect(wrapper.emitted('changed')[0][0]).toMatchObject({
        vulnerabilities_allowed: 3,
      });
    });
  });

  describe('remove scanner', () => {
    it('passes showRemoveButton prop to scanner header', () => {
      createComponent();

      expect(findScannerHeader().props('showRemoveButton')).toBe(true);
    });

    it('emits remove event when scanner header emits remove', () => {
      createComponent();

      findScannerHeader().vm.$emit('remove');

      expect(wrapper.emitted('remove')).toHaveLength(1);
    });
  });

  describe('default configuration badge', () => {
    it('passes isDefaultConfiguration to scanner header when provided', () => {
      createComponent(defaultRule, { isDefaultConfiguration: true });

      expect(findScannerHeader().props('isDefaultConfiguration')).toBe(true);
    });

    it('passes false isDefaultConfiguration by default', () => {
      createComponent();

      expect(findScannerHeader().props('isDefaultConfiguration')).toBe(false);
    });

    it('passes showDefaultRuleBadge to scanner header when provided', () => {
      createComponent(defaultRule, { showDefaultRuleBadge: true });

      expect(findScannerHeader().props('showDefaultRuleBadge')).toBe(true);
    });

    it('does not show default rule badge by default', () => {
      createComponent();

      expect(findScannerHeader().props('showDefaultRuleBadge')).toBe(false);
    });

    it('emits reset event when scanner header emits reset', () => {
      createComponent(defaultRule, { isDefaultConfiguration: false });

      findScannerHeader().vm.$emit('reset');

      expect(wrapper.emitted('reset')).toHaveLength(1);
    });
  });

  describe('enrichment data settings', () => {
    it('renders enrichment data settings with default block action', () => {
      createComponent();

      expect(findEnrichmentDataSettings().exists()).toBe(true);
      expect(findEnrichmentDataSettings().props('selectedAction')).toBe(
        ENRICHMENT_DATA_ACTIONS.BLOCK,
      );
    });

    it('loads saved enrichment_data_unavailable action from scanner', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0.5 },
          [ENRICHMENT_DATA_UNAVAILABLE]: { action: ENRICHMENT_DATA_ACTIONS.IGNORE },
        },
      });

      expect(findEnrichmentDataSettings().props('selectedAction')).toBe(
        ENRICHMENT_DATA_ACTIONS.IGNORE,
      );
    });

    it('emits changed event with updated enrichment_data_unavailable when action changes', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0.5 },
          [FIX_AVAILABLE]: true,
        },
      });

      findEnrichmentDataSettings().vm.$emit('change', ENRICHMENT_DATA_ACTIONS.IGNORE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted).toHaveProperty(ENRICHMENT_DATA_UNAVAILABLE, {
        action: ENRICHMENT_DATA_ACTIONS.IGNORE,
      });
      // Should also preserve other attributes
      expect(emitted).toHaveProperty(KNOWN_EXPLOITED);
      expect(emitted).toHaveProperty(EPSS_SCORE);
      expect(emitted).toHaveProperty(FIX_AVAILABLE);
    });

    it('preserves enrichment_data_unavailable when editing other attributes', () => {
      createComponent({
        ...defaultRule,
        vulnerability_attributes: {
          [KNOWN_EXPLOITED]: true,
          [EPSS_SCORE]: { operator: GREATER_THAN_OPERATOR, value: 0.5 },
          [FIX_AVAILABLE]: true,
          [ENRICHMENT_DATA_UNAVAILABLE]: { action: ENRICHMENT_DATA_ACTIONS.IGNORE },
        },
      });

      findAttributeFilters().vm.$emit('remove', FIX_AVAILABLE);

      expect(wrapper.emitted('changed')).toHaveLength(1);
      const emitted = wrapper.emitted('changed')[0][0].vulnerability_attributes;
      expect(emitted).toHaveProperty(ENRICHMENT_DATA_UNAVAILABLE, {
        action: ENRICHMENT_DATA_ACTIONS.IGNORE,
      });
    });
  });
});
