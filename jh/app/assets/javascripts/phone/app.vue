<script>
import PhoneForm from './components/phone_form.vue';
import { GREETING_MESSAGE, REGULATIONS } from './constants';

export default {
  name: 'PhoneVerificationApp',
  components: {
    PhoneForm,
  },
  i18n: {
    GREETING_MESSAGE,
    REGULATIONS,
  },
};
</script>

<template>
  <div class="jh-pv-wrapper gl-mt-4">
    <h1 class="gl-text-center">
      {{ $options.i18n.GREETING_MESSAGE }}
    </h1>
    <p class="gl-text-center">
      {{ $options.i18n.REGULATIONS }}
    </p>
    <div class="phone-verification-form">
      <phone-form />
    </div>
  </div>
</template>
