<script>
import { GlForm, GlButton, GlFormGroup, GlFormInput } from '@gitlab/ui';
import EECompanyForm from 'ee/registrations/components/company_form.vue';
import FormErrorTracker from '~/pages/shared/form_error_tracker';
import CountryOrRegionSelector from 'jh/trials/components/country_or_region_selector.vue';
import {
  PREMIUM_TRIAL_FORM_SUBMIT_TEXT,
  PREMIUM_TRIAL_FOOTER_DESCRIPTION,
} from 'jh/registrations/constants';

export default {
  components: {
    GlForm,
    GlButton,
    GlFormGroup,
    GlFormInput,
    CountryOrRegionSelector,
  },
  extends: EECompanyForm,
  data() {
    return {
      ...this.user,
      phoneNumber: null,
      country: 'CN',
      state: window.gon.dot_com && window.location.hostname === 'gitlab.hk' ? 'HK' : 'BJ',
      tracker: null,
    };
  },
  mounted() {
    this.tracker = new FormErrorTracker();
  },
  beforeDestroy() {
    this.tracker.destroy();
  },
  i18n: {
    ...EECompanyForm.i18n,
    formSubmitText: {
      ...EECompanyForm.i18n.formSubmitText,
      registration: PREMIUM_TRIAL_FORM_SUBMIT_TEXT,
    },
    footerDescriptionRegistration: {
      trial: '',
      registration: PREMIUM_TRIAL_FOOTER_DESCRIPTION,
    },
  },
};
</script>

<template>
  <gl-form
    :action="submitPath"
    class="gl-show-field-errors gl-border-1 gl-border-solid gl-border-default gl-p-6"
    method="post"
    @submit="trackCompanyForm"
  >
    <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
    <p data-testid="description" class="gl-mt-2">{{ $options.i18n.description }}</p>
    <div v-show="user.showNameFields" class="gl-flex gl-flex-col sm:gl-flex-row">
      <gl-form-group
        :label="$options.i18n.firstNameLabel"
        label-size="sm"
        label-for="first_name"
        class="gl-mr-5 gl-w-full sm:gl-w-1/2"
      >
        <gl-form-input
          id="first_name"
          :value="user.firstName"
          name="first_name"
          class="js-track-error"
          data-testid="first_name"
          :data-track-action-for-errors="trackActionForErrors"
          required
        />
      </gl-form-group>
      <gl-form-group
        :label="$options.i18n.lastNameLabel"
        label-size="sm"
        label-for="last_name"
        class="gl-w-full sm:gl-w-1/2"
      >
        <gl-form-input
          id="last_name"
          :value="user.lastName"
          name="last_name"
          class="js-track-error"
          data-testid="last_name"
          :data-track-action-for-errors="trackActionForErrors"
          required
        />
      </gl-form-group>
    </div>
    <gl-form-group :label="$options.i18n.companyNameLabel" label-size="sm" label-for="company_name">
      <gl-form-input
        id="company_name"
        :value="user.companyName"
        name="company_name"
        class="js-track-error"
        data-testid="company_name"
        :data-track-action-for-errors="trackActionForErrors"
        required
      />
    </gl-form-group>
    <country-or-region-selector
      class="gl-hidden"
      :country="country"
      :state="state"
      data-testid="country"
      :track-action-for-errors="trackActionForErrors"
      required
    />

    <gl-form-group
      :label="$options.i18n.phoneNumberLabel"
      :optional-text="$options.i18n.optional"
      label-size="sm"
      :description="$options.i18n.phoneNumberDescription"
      label-for="phone_number"
      optional
    >
      <gl-form-input
        id="phone_number"
        :value="phoneNumber"
        name="phone_number"
        type="tel"
        data-testid="phone_number"
        pattern="^(\+)*[0-9\-\s]+$"
      />
    </gl-form-group>
    <gl-button type="submit" variant="confirm" class="gl-w-full">
      {{ formSubmitText }}
    </gl-button>
  </gl-form>
</template>
