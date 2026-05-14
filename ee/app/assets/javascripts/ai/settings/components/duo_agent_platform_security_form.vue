<script>
import { GlFormCheckbox, GlFormGroup } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'DuoAgentPlatformSecurityForm',
  components: {
    GlFormCheckbox,
    GlFormGroup,
  },
  i18n: {
    securityHeading: s__('AiPowered|Security'),
    secureCheckboxLabel: s__('AiPowered|Use TLS for the GitLab Duo Agent Platform service'),
    secureCheckboxHelpText: s__(
      'AiPowered|Turn off only if your local service endpoint does not support TLS.',
    ),
  },
  inject: ['selfHostedDuoAgentPlatformServiceSecureEnabled'],
  emits: ['secure-change'],
  data() {
    return {
      selfHostedDuoAgentPlatformServiceSecureChecked:
        this.selfHostedDuoAgentPlatformServiceSecureEnabled,
    };
  },
  methods: {
    onSecureValueChange(value) {
      this.$emit('secure-change', value);
    },
  },
};
</script>
<template>
  <gl-form-group
    :label="$options.i18n.securityHeading"
    label-for="duo-agent-platform-security-form"
    class="gl-mb-2 gl-mt-5"
  >
    <gl-form-checkbox
      v-model="selfHostedDuoAgentPlatformServiceSecureChecked"
      @change="onSecureValueChange"
    >
      <span data-testid="secure-checkbox-label">{{ $options.i18n.secureCheckboxLabel }}</span>
      <template #help>
        <span data-testid="secure-checkbox-help-text">
          {{ $options.i18n.secureCheckboxHelpText }}
        </span>
      </template>
    </gl-form-checkbox>
  </gl-form-group>
</template>
