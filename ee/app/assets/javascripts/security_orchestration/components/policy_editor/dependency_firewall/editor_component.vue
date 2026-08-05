<script>
import { s__ } from '~/locale';
import { extractPolicyContent, fromYaml } from 'ee/security_orchestration/components/utils';
import {
  policyBodyToYaml,
  policyToYaml,
} from 'ee/security_orchestration/components/policy_editor/utils';
import { EDITOR_MODE_YAML, SECURITY_POLICY_ACTIONS } from '../constants';
import EditorLayout from '../editor_layout.vue';
import { DEPENDENCY_FIREWALL_POLICY_TYPE } from '../../constants';

export const DEFAULT_DEPENDENCY_FIREWALL_POLICY = `dependency_firewall_policy:
  - name: ''
    enabled: true
    enforcement_type: enforced
    rules:
      - type: license
`;

const YAML_ONLY_MODE = { value: EDITOR_MODE_YAML, text: s__('SecurityOrchestration|.yaml mode') };

export default {
  name: 'DependencyFirewallEditorComponent',
  EDITOR_MODE_YAML,
  SECURITY_POLICY_ACTIONS,
  YAML_ONLY_MODES: [YAML_ONLY_MODE],
  i18n: {},
  components: {
    EditorLayout,
  },
  props: {
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
    isCreating: {
      type: Boolean,
      required: true,
    },
    isDeleting: {
      type: Boolean,
      required: true,
    },
    isEditing: {
      type: Boolean,
      required: true,
    },
    selectedPolicyType: {
      type: String,
      required: true,
    },
  },
  emits: ['save'],
  data() {
    const yamlEditorValue = this.existingPolicy
      ? policyToYaml(this.existingPolicy, this.selectedPolicyType)
      : DEFAULT_DEPENDENCY_FIREWALL_POLICY;

    const policy = fromYaml({ manifest: yamlEditorValue, type: DEPENDENCY_FIREWALL_POLICY_TYPE });

    return {
      policy,
      yamlEditorValue,
    };
  },
  methods: {
    async handleModifyPolicy(action) {
      const policy = extractPolicyContent({
        manifest: this.yamlEditorValue,
        type: this.selectedPolicyType,
        withType: true,
      });

      this.$emit('save', {
        action,
        policy: policyBodyToYaml(policy),
      });
    },
    handleUpdateYaml(manifest) {
      this.yamlEditorValue = manifest;
      this.policy = fromYaml({ manifest, type: DEPENDENCY_FIREWALL_POLICY_TYPE });
    },
  },
};
</script>
<template>
  <editor-layout
    :default-editor-mode="$options.EDITOR_MODE_YAML"
    :editor-modes="$options.YAML_ONLY_MODES"
    :is-editing="isEditing"
    :is-removing-policy="isDeleting"
    :is-updating-policy="isCreating"
    :policy="policy"
    :yaml-editor-value="yamlEditorValue"
    @remove-policy="handleModifyPolicy($options.SECURITY_POLICY_ACTIONS.REMOVE)"
    @save-policy="handleModifyPolicy"
    @update-yaml="handleUpdateYaml"
  />
</template>
