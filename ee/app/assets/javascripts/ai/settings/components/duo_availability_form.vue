<script>
import { GlSprintf, GlFormRadioGroup, GlFormRadio, GlFormGroup } from '@gitlab/ui';
import { s__ } from '~/locale';
import CascadingLockIcon from '~/namespaces/cascading_settings/components/cascading_lock_icon.vue';
import { AVAILABILITY_OPTIONS } from '../constants';

const IS_SAAS_ATTRIBUTE = true;
const IS_SELF_MANAGED_ATTRIBUTE = false;

export default {
  name: 'DuoAvailabilityForm',
  availabilityOptions: {
    alwaysOn: AVAILABILITY_OPTIONS.ALWAYS_ON,
    defaultOn: AVAILABILITY_OPTIONS.DEFAULT_ON,
    defaultOff: AVAILABILITY_OPTIONS.DEFAULT_OFF,
    alwaysOff: AVAILABILITY_OPTIONS.NEVER_ON,
  },
  i18n: {
    subtitle: {
      [IS_SAAS_ATTRIBUTE]: s__('AiPowered|Control whether GitLab Duo is available for this group.'),
      [IS_SELF_MANAGED_ATTRIBUTE]: s__(
        'AiPowered|Control whether GitLab Duo is available for the instance.',
      ),
    },
    alwaysOnText: s__('AiPowered|Always on'),
    alwaysOnHelpText: {
      [IS_SAAS_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is always available. Subgroups and projects cannot opt out.',
      ),
      [IS_SELF_MANAGED_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is always available. Groups, subgroups, and projects cannot opt out.',
      ),
    },
    defaultOnText: s__('AiPowered|On by default'),
    defaultOnHelpText: {
      [IS_SAAS_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is available by default. Subgroups and projects can opt out individually.',
      ),
      [IS_SELF_MANAGED_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is available by default. Groups, subgroups, and projects can opt out individually.',
      ),
    },
    defaultOffText: s__('AiPowered|Off by default'),
    defaultOffHelpText: {
      [IS_SAAS_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is unavailable by default. Subgroups and projects can opt in individually.',
      ),
      [IS_SELF_MANAGED_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is unavailable by default. Groups, subgroups, and projects can opt in individually.',
      ),
    },
    alwaysOffText: s__('AiPowered|Always off'),
    alwaysOffHelpText: {
      [IS_SAAS_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is always unavailable. Subgroups and projects cannot opt in.',
      ),
      [IS_SELF_MANAGED_ATTRIBUTE]: s__(
        'AiPowered|GitLab Duo is always unavailable. Groups, subgroups, and projects cannot opt in.',
      ),
    },
  },
  components: {
    GlSprintf,
    GlFormRadioGroup,
    GlFormRadio,
    GlFormGroup,
    CascadingLockIcon,
  },
  inject: ['isSaaS', 'areDuoSettingsLocked', 'duoAvailabilityCascadingSettings'],
  props: {
    duoAvailability: {
      type: String,
      required: true,
    },
  },
  emits: ['change'],
  data() {
    return {
      duoAvailabilityState: this.duoAvailability,
    };
  },
  computed: {
    showCascadingButton() {
      return (
        this.areDuoSettingsLocked &&
        this.duoAvailabilityCascadingSettings &&
        Object.keys(this.duoAvailabilityCascadingSettings).length
      );
    },
  },
  methods: {
    radioChanged() {
      this.$emit('change', this.duoAvailabilityState);
    },
  },
};
</script>
<template>
  <div>
    <gl-form-group
      :label="s__('AiPowered|GitLab Duo availability')"
      :label-description="$options.i18n.subtitle[isSaaS]"
    >
      <gl-form-radio-group v-model="duoAvailabilityState">
        <gl-form-radio
          :value="$options.availabilityOptions.alwaysOn"
          :disabled="areDuoSettingsLocked"
          @change="radioChanged"
        >
          {{ $options.i18n.alwaysOnText }}
          <template #help>
            <gl-sprintf :message="$options.i18n.alwaysOnHelpText[isSaaS]" />
          </template>
        </gl-form-radio>

        <gl-form-radio
          :value="$options.availabilityOptions.defaultOn"
          :disabled="areDuoSettingsLocked"
          @change="radioChanged"
        >
          {{ $options.i18n.defaultOnText }}

          <template #help>
            <gl-sprintf :message="$options.i18n.defaultOnHelpText[isSaaS]" />
          </template>
        </gl-form-radio>

        <slot name="amazon-q-settings"></slot>

        <gl-form-radio
          :value="$options.availabilityOptions.defaultOff"
          :disabled="areDuoSettingsLocked"
          @change="radioChanged"
        >
          {{ $options.i18n.defaultOffText }}
          <template #help>
            <gl-sprintf :message="$options.i18n.defaultOffHelpText[isSaaS]" />
          </template>
        </gl-form-radio>

        <gl-form-radio
          :value="$options.availabilityOptions.alwaysOff"
          :disabled="areDuoSettingsLocked"
          @change="radioChanged"
        >
          {{ $options.i18n.alwaysOffText }}
          <cascading-lock-icon
            v-if="showCascadingButton"
            :is-locked-by-group-ancestor="duoAvailabilityCascadingSettings.lockedByAncestor"
            :is-locked-by-application-settings="
              duoAvailabilityCascadingSettings.lockedByApplicationSetting
            "
            :ancestor-namespace="duoAvailabilityCascadingSettings.ancestorNamespace"
            class="gl-ml-1"
          />
          <template #help>
            <gl-sprintf :message="$options.i18n.alwaysOffHelpText[isSaaS]" />
          </template>
        </gl-form-radio>
      </gl-form-radio-group>
    </gl-form-group>
  </div>
</template>
