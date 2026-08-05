<script>
import { GlAlert, GlButton, GlFormRadio, GlModal, GlModalDirective, GlSprintf } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import cdRolloutCreateMutation from '../graphql/cd_rollout_create.mutation.graphql';

export default {
  name: 'TriggerDeployment',
  components: {
    GlAlert,
    GlButton,
    GlFormRadio,
    GlModal,
    GlSprintf,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    organizationId: {
      type: String,
      required: true,
    },
    versionSetId: {
      type: String,
      required: true,
    },
    releaseName: {
      type: String,
      required: true,
    },
  },
  emits: ['deploy-triggered'],
  modalId: 'cd-trigger-deployment-modal',
  data() {
    return {
      isTriggering: false,
      deploymentErrors: [],
      selectedFlow: 'main',
    };
  },
  computed: {
    modalTitle() {
      return sprintf(s__('ContinuousDeployment|Trigger deployment — %{name}'), {
        name: this.releaseName,
      });
    },
    modalActionPrimary() {
      return {
        text: s__('ContinuousDeployment|Trigger deployment'),
        attributes: { variant: 'confirm', size: 'small', loading: this.isTriggering },
      };
    },
    modalActionCancel() {
      return {
        text: __('Cancel'),
        attributes: { size: 'small', disabled: this.isTriggering },
      };
    },
  },
  watch: {
    versionSetId() {
      this.deploymentErrors = [];
      this.selectedFlow = 'main';
    },
  },
  methods: {
    onModalHidden() {
      this.deploymentErrors = [];
    },
    async triggerDeployment(event) {
      // Keep the modal open until the mutation resolves.
      event.preventDefault();

      this.isTriggering = true;
      this.deploymentErrors = [];

      try {
        const { data } = await this.$apollo.mutate({
          mutation: cdRolloutCreateMutation,
          variables: {
            input: {
              organizationId: this.organizationId,
              versionSetId: this.versionSetId,
            },
          },
        });

        const errors = data?.cdRolloutCreate?.errors ?? [];
        if (errors.length) {
          this.deploymentErrors = errors;
          return;
        }

        this.$refs.modal.hide();
        this.$emit('deploy-triggered');
      } catch (error) {
        this.deploymentErrors = [
          s__('ContinuousDeployment|Failed to trigger the deployment. Please try again.'),
        ];
        Sentry.captureException(error);
      } finally {
        this.isTriggering = false;
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-button
      v-gl-modal="$options.modalId"
      variant="confirm"
      size="small"
      class="gl-mt-5"
      data-testid="trigger-deployment-button"
    >
      {{ s__('ContinuousDeployment|Trigger deployment') }}
    </gl-button>

    <gl-modal
      ref="modal"
      :modal-id="$options.modalId"
      :title="modalTitle"
      :action-primary="modalActionPrimary"
      :action-cancel="modalActionCancel"
      @primary="triggerDeployment"
      @hidden="onModalHidden"
    >
      <gl-alert
        v-if="deploymentErrors.length"
        variant="danger"
        class="gl-mb-4"
        data-testid="deployment-error-alert"
        @dismiss="deploymentErrors = []"
      >
        <ul v-if="deploymentErrors.length > 1" class="gl-m-0 gl-pl-5">
          <li v-for="(error, index) in deploymentErrors" :key="index">{{ error }}</li>
        </ul>
        <template v-else>{{ deploymentErrors[0] }}</template>
      </gl-alert>

      <p class="gl-mb-0 gl-text-secondary">
        <gl-sprintf
          :message="
            s__(
              'ContinuousDeployment|Trigger a manual deployment of %{name}. Pick the flow to run.',
            )
          "
        >
          <template #name>
            <strong>{{ releaseName }}</strong>
          </template>
        </gl-sprintf>
      </p>

      <label class="gl-mb-2 gl-mt-4 gl-block gl-text-sm gl-font-bold">
        {{ s__('ContinuousDeployment|Flow') }}
      </label>

      <div class="gl-mb-5 gl-rounded-base gl-border-1 gl-border-solid gl-border-default gl-p-4">
        <gl-form-radio v-model="selectedFlow" value="main" class="-gl-mb-3">
          <span class="gl-flex gl-items-center gl-gap-2">
            <span class="gl-font-bold">{{
              s__('ContinuousDeployment|Latest deployment flow')
            }}</span>
            <span class="gl-text-subtle">&middot;</span>
            <span class="gl-text-subtle">{{ s__('ContinuousDeployment|default') }}</span>
          </span>
        </gl-form-radio>
      </div>

      <gl-alert variant="info" :dismissible="false" class="gl-mt-4">
        {{
          s__(
            'ContinuousDeployment|This deployment will honour all policies and approval gates configured for the target environments.',
          )
        }}
      </gl-alert>
    </gl-modal>
  </div>
</template>
