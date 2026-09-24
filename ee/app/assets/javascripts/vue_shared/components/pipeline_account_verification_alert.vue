<script>
import { GlAlert } from '@gitlab/ui';
import { s__ } from '~/locale';

const DEFAULT_TITLE = s__(
  'IdentityVerification|Before you can run pipelines, we need to verify your account.',
);
const DEFAULT_DESCRIPTION = s__(
  `IdentityVerification|We won't ask you for this information again. It will never be used for marketing purposes.`,
);
const DEFAULT_BUTTON_TEXT = s__('IdentityVerification|Verify my account');

export default {
  name: 'PipelineAccountVerificationAlert',
  components: { GlAlert },
  inject: ['identityVerificationRequired', 'identityVerificationPath'],
  props: {
    title: {
      type: String,
      required: false,
      default: DEFAULT_TITLE,
    },
    description: {
      type: String,
      required: false,
      default: DEFAULT_DESCRIPTION,
    },
    buttonText: {
      type: String,
      required: false,
      default: DEFAULT_BUTTON_TEXT,
    },
    dismissible: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      isVisible: true,
    };
  },
  methods: {
    dismissAlert() {
      this.isVisible = false;
    },
  },
};
</script>

<template>
  <gl-alert
    v-if="identityVerificationRequired && isVisible"
    :title="title"
    :primary-button-text="buttonText"
    :primary-button-link="identityVerificationPath"
    :dismissible="dismissible"
    variant="danger"
    @dismiss="dismissAlert"
  >
    {{ description }}
  </gl-alert>
</template>
