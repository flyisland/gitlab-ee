import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import EditorComponent, {
  DEFAULT_DEPENDENCY_FIREWALL_POLICY,
} from 'ee/security_orchestration/components/policy_editor/dependency_firewall/editor_component.vue';
import EditorLayout from 'ee/security_orchestration/components/policy_editor/editor_layout.vue';
import {
  EDITOR_MODE_YAML,
  SECURITY_POLICY_ACTIONS,
} from 'ee/security_orchestration/components/policy_editor/constants';
import { DEPENDENCY_FIREWALL_POLICY_TYPE } from 'ee/security_orchestration/components/constants';
import { ASSIGNED_POLICY_PROJECT } from 'ee_jest/security_orchestration/mocks/mock_data';

const mockExistingPolicy = {
  name: 'existing-dfw-policy',
  enabled: true,
  enforcement_type: 'enforced',
  rules: [{ type: 'license' }],
};

const mockExistingPolicyYaml = `dependency_firewall_policy:
  - name: existing-dfw-policy
    enabled: true
    enforcement_type: enforced
    rules:
      - type: license
`;

describe('DependencyFirewall EditorComponent', () => {
  let wrapper;

  const factory = ({ propsData = {} } = {}) => {
    wrapper = shallowMountExtended(EditorComponent, {
      propsData: {
        selectedPolicyType: DEPENDENCY_FIREWALL_POLICY_TYPE,
        isCreating: false,
        isDeleting: false,
        isEditing: false,
        ...propsData,
      },
    });
  };

  const factoryWithExistingPolicy = ({ policy = {} } = {}) => {
    return factory({
      propsData: {
        assignedPolicyProject: ASSIGNED_POLICY_PROJECT,
        existingPolicy: { ...mockExistingPolicy, ...policy },
        isEditing: true,
      },
    });
  };

  const findEditorLayout = () => wrapper.findComponent(EditorLayout);

  describe('default state (new policy)', () => {
    beforeEach(() => {
      factory();
    });

    it('renders EditorLayout', () => {
      expect(findEditorLayout().exists()).toBe(true);
    });

    it('initializes with default YAML', () => {
      expect(findEditorLayout().props('yamlEditorValue')).toBe(DEFAULT_DEPENDENCY_FIREWALL_POLICY);
    });

    it('starts in YAML-only mode', () => {
      expect(findEditorLayout().props('defaultEditorMode')).toBe(EDITOR_MODE_YAML);
    });

    it('exposes only YAML mode option', () => {
      const modes = findEditorLayout().props('editorModes');
      expect(modes).toHaveLength(1);
      expect(modes[0].value).toBe(EDITOR_MODE_YAML);
    });

    it('passes correct loading state props', () => {
      expect(findEditorLayout().props('isEditing')).toBe(false);
      expect(findEditorLayout().props('isRemovingPolicy')).toBe(false);
      expect(findEditorLayout().props('isUpdatingPolicy')).toBe(false);
    });
  });

  describe('with existing policy', () => {
    beforeEach(() => {
      factoryWithExistingPolicy();
    });

    it('initializes YAML from existing policy', () => {
      expect(findEditorLayout().props('yamlEditorValue')).toBe(mockExistingPolicyYaml);
    });

    it('passes isEditing prop', () => {
      expect(findEditorLayout().props('isEditing')).toBe(true);
    });
  });

  describe('YAML update', () => {
    it('updates yamlEditorValue when update-yaml is emitted', async () => {
      factory();
      const newYaml = `dependency_firewall_policy:\n  - name: updated\n    enabled: false\n    enforcement_type: enforced\n    rules:\n      - type: license\n`;

      await findEditorLayout().vm.$emit('update-yaml', newYaml);

      expect(findEditorLayout().props('yamlEditorValue')).toBe(newYaml);
    });
  });

  describe('save flow', () => {
    it('emits save with correct action on save-policy', async () => {
      factory();
      findEditorLayout().vm.$emit('save-policy');
      await waitForPromises();

      expect(wrapper.emitted('save')).toHaveLength(1);
      expect(wrapper.emitted('save')[0][0]).toMatchObject({
        action: undefined,
      });
      expect(wrapper.emitted('save')[0][0].policy).toContain('type: dependency_firewall_policy');
    });

    it('emits save with REPLACE action when save-policy emits action', async () => {
      factoryWithExistingPolicy();
      findEditorLayout().vm.$emit('save-policy', SECURITY_POLICY_ACTIONS.REPLACE);
      await waitForPromises();

      expect(wrapper.emitted('save')[0][0]).toMatchObject({
        action: SECURITY_POLICY_ACTIONS.REPLACE,
      });
    });

    it('emits save with REMOVE action on remove-policy', async () => {
      factoryWithExistingPolicy();
      findEditorLayout().vm.$emit('remove-policy');
      await waitForPromises();

      expect(wrapper.emitted('save')[0][0]).toMatchObject({
        action: SECURITY_POLICY_ACTIONS.REMOVE,
      });
    });
  });
});
