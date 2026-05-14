<script>
import { GlIcon, GlPopover } from '@gitlab/ui';
// eslint-disable-next-line no-restricted-imports
import { mapActions, mapState } from 'vuex';
import { s__ } from '~/locale';
import {
  ENFORCE_VALUE,
  WARN_VALUE,
} from 'ee/security_orchestration/components/policy_editor/scan_result/lib';
import PolicyOverrideText from './policy_override_text.vue';

export default {
  i18n: {
    title: s__('SecurityOrchestration|Policy override'),
    popoverTextSingle: s__(
      'SecurityOrchestration|Some settings may be affected by policy %{policyName} based on its rules.',
    ),
    popoverTextMultiple: s__(
      'SecurityOrchestration|Some settings may be affected by the following policies based on their rules:',
    ),
  },
  name: 'PolicyOverrideWarningIcon',
  components: {
    GlIcon,
    GlPopover,
    PolicyOverrideText,
  },
  inject: {
    fullPath: {
      type: String,
    },
    isGroup: {
      type: Boolean,
      default: false,
    },
  },
  props: {
    iconId: {
      type: String,
      required: false,
      default: 'policy-override-warning-icon',
    },
    settings: {
      type: Array,
      required: true,
    },
  },
  computed: {
    ...mapState({
      scanResultPolicies: (state) => state.securityOrchestrationModule.scanResultPolicies || [],
    }),
    policiesWithSettingsOverride() {
      return this.scanResultPolicies.filter(this.hasSettingsOverride);
    },
    enforcedPoliciesWithSettingsOverride() {
      return this.policiesWithSettingsOverride.filter(
        (policy) => policy.enforcement_type === ENFORCE_VALUE,
      );
    },
    warnPoliciesWithSettingsOverride() {
      return this.policiesWithSettingsOverride.filter(
        (policy) => policy.enforcement_type === WARN_VALUE,
      );
    },
    hasApprovalSettingsOverride() {
      return this.policiesWithSettingsOverride.length > 0;
    },
  },
  created() {
    const { fullPath, isGroup } = this;
    this.fetchScanResultPolicies({ fullPath, isGroup });
  },
  methods: {
    ...mapActions('securityOrchestrationModule', ['fetchScanResultPolicies']),
    hasSettingsOverride({ approval_settings, enabled }) {
      if (!enabled) {
        return false;
      }

      // eslint-disable-next-line camelcase
      return Object.entries(approval_settings ?? {}).some(([setting, value]) => {
        return this.settings?.includes(setting) && Boolean(value);
      });
    },
  },
};
</script>

<template>
  <div v-if="hasApprovalSettingsOverride">
    <gl-popover :title="$options.i18n.title" :target="iconId" show-close-button>
      <policy-override-text
        v-if="enforcedPoliciesWithSettingsOverride.length"
        :policies="enforcedPoliciesWithSettingsOverride"
      />
      <policy-override-text
        v-if="warnPoliciesWithSettingsOverride.length"
        :policies="warnPoliciesWithSettingsOverride"
        is-warn
      />
    </gl-popover>

    <gl-icon :id="iconId" name="warning" />
  </div>
</template>
