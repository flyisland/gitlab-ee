<script>
import { GlFormCheckbox, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { titleText, labelText, descriptionText } from '../constants';

export default {
  components: {
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
  },
  inject: [
    'passwordExpirationEnabledData',
    'passwordExpiresInDaysData',
    'passwordExpiresNoticeBeforeDaysData',
  ],
  data() {
    return {
      passwordExpirationEnabled: this.passwordExpirationEnabledData,
      passwordExpiresInDays: this.passwordExpiresInDaysData,
      passwordExpiresNoticeBeforeDays: this.passwordExpiresNoticeBeforeDaysData,
    };
  },
  titleText,
  labelText,
  descriptionText,
};
</script>
<template>
  <div>
    <div class="gl-mb-5">
      <label>{{ $options.titleText }}</label>
      <gl-form-checkbox v-model="passwordExpirationEnabled" data-testid="expire-checkbox">
        <span>{{ $options.labelText.isEnableExpiration }}</span>
      </gl-form-checkbox>
      <input
        :value="passwordExpirationEnabled"
        type="hidden"
        name="application_setting[password_expiration_enabled]"
      />
    </div>

    <gl-form-group
      class="!gl-mb-5"
      :label="$options.labelText.inDays"
      label-class="!gl-font-normal"
      :description="$options.descriptionText.inDays"
      data-testid="password-expiration-in-days"
    >
      <gl-form-input
        v-model="passwordExpiresInDays"
        :disabled="!passwordExpirationEnabled"
        name="application_setting[password_expires_in_days]"
        type="number"
        data-testid="expire-in-days-field"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.labelText.beforeDays"
      label-class="!gl-font-normal"
      :description="$options.descriptionText.beforeDays"
      data-testid="password-expires-notice-days"
    >
      <gl-form-input
        v-model="passwordExpiresNoticeBeforeDays"
        :disabled="!passwordExpirationEnabled"
        name="application_setting[password_expires_notice_before_days]"
        type="number"
        data-testid="expire-notify-field"
      />
    </gl-form-group>
  </div>
</template>
