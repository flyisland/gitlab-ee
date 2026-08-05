<script>
import { GlAlert, GlForm, GlFormInput, GlCollapsibleListbox, GlButton } from '@gitlab/ui';
import { produce } from 'immer';
import { MountingPortal } from 'portal-vue';
import { __, s__, sprintf } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import { ENVIRONMENT_FILTERS, MAX_NAME_LENGTH } from '../constants';
import cdEnvironmentCreateMutation from '../graphql/cd_environment_create.mutation.graphql';
import cdEnvironmentTiersQuery from '../graphql/cd_environment_tiers.query.graphql';
import cdEnvironmentsQuery from '../graphql/cd_environments.query.graphql';
import PanelFormField from './shared/panel_form_field.vue';
import PanelFormGroup from './shared/panel_form_group.vue';

export default {
  name: 'NewEnvironmentPanel',
  components: {
    GlAlert,
    GlForm,
    GlFormInput,
    GlCollapsibleListbox,
    GlButton,
    DynamicPanel,
    MountingPortal,
    PanelFormField,
    PanelFormGroup,
  },
  props: {
    open: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['close'],
  data() {
    return {
      organization: null,
      name: '',
      tier: null,
      errors: undefined,
      isSubmitting: false,
      wasValidated: false,
    };
  },
  apollo: {
    organization: {
      query: cdEnvironmentTiersQuery,
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    tiers() {
      return this.organization?.cdEnvironmentTiers || [];
    },
    tierItems() {
      return this.tiers.map((tier) => ({ value: tier, text: ENVIRONMENT_FILTERS[tier] }));
    },
    isNameValid() {
      return this.name.length > 0 && this.name.length <= MAX_NAME_LENGTH;
    },
    nameState() {
      if (this.name.length > MAX_NAME_LENGTH) {
        return false;
      }
      return this.wasValidated && !this.isNameValid ? false : null;
    },
    nameInvalidFeedback() {
      if (this.name.length > MAX_NAME_LENGTH) {
        return sprintf(s__('ContinuousDeployment|Name cannot exceed %{maxLength} characters.'), {
          maxLength: MAX_NAME_LENGTH,
        });
      }
      return s__('ContinuousDeployment|Name is required.');
    },
  },
  watch: {
    tiers: {
      immediate: true,
      handler(tiers) {
        if (tiers.length && !this.tier) {
          [this.tier] = tiers;
        }
      },
    },
  },
  methods: {
    async onSubmit() {
      this.wasValidated = true;

      if (!this.isNameValid || !this.organization) {
        return;
      }

      try {
        this.isSubmitting = true;

        const { data } = await this.$apollo.mutate({
          mutation: cdEnvironmentCreateMutation,
          variables: {
            input: {
              name: this.name,
              tier: this.tier,
              organizationId: this.organization.id,
            },
          },
          update: (cache, { data: { cdEnvironmentCreate } }) => {
            if (!cdEnvironmentCreate.environment) {
              return;
            }
            const sourceData = cache.readQuery({ query: cdEnvironmentsQuery });

            if (!sourceData) {
              return;
            }

            cache.writeQuery({
              query: cdEnvironmentsQuery,
              data: produce(sourceData, (draftState) => {
                draftState.organization.cdEnvironments.nodes.push(cdEnvironmentCreate.environment);
              }),
            });
          },
        });

        const { errors } = data.cdEnvironmentCreate;

        if (errors.length) {
          this.errors = errors;
          return;
        }

        this.handleClose();
      } catch (error) {
        Sentry.captureException(error);
        this.errors = [__('An error occurred. Please try again.')];
      } finally {
        this.isSubmitting = false;
      }
    },
    handleClose() {
      this.$emit('close');
      this.clearForm();
    },
    clearForm() {
      this.name = '';
      this.tier = this.tiers[0] ?? null;
      this.errors = undefined;
      this.wasValidated = false;
    },
  },
};
</script>

<template>
  <mounting-portal v-if="open" mount-to="#contextual-panel-portal" append>
    <dynamic-panel data-testid="environment-panel" @close="handleClose">
      <template #header>
        <div class="gl-py-3">
          <p
            class="gl-mb-2 gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-status-brand"
          >
            {{ s__('ContinuousDeployment|Add Environment') }}
          </p>
          <h3 class="gl-my-0 gl-text-base">
            {{ s__('ContinuousDeployment|Register environment') }}
          </h3>
        </div>
      </template>

      <p class="gl-my-5 gl-text-subtle">
        {{
          s__(
            'ContinuousDeployment|Register the cluster or cloud account where services will run. Agent registration is included.',
          )
        }}
      </p>

      <gl-form
        ref="form"
        :aria-label="s__('ContinuousDeployment|Register environment')"
        class="gl-w-full"
        @submit.prevent="onSubmit"
      >
        <panel-form-group
          :description="s__('ContinuousDeployment|A short name and the tier it represents.')"
          step="1"
          :title="s__('ContinuousDeployment|Environment identity')"
        >
          <gl-alert v-if="errors" class="gl-mt-4" variant="danger" @dismiss="errors = undefined">
            <ul class="gl-m-0 gl-pl-4">
              <li v-for="error in errors" :key="error">
                {{ error }}
              </li>
            </ul>
          </gl-alert>
          <div class="gl-flex gl-gap-3">
            <panel-form-field
              class="gl-grow"
              :label="s__('ContinuousDeployment|Environment name')"
              :state="nameState"
              :invalid-feedback="nameInvalidFeedback"
            >
              <gl-form-input
                id="environment-name"
                v-model="name"
                :state="nameState"
                :placeholder="s__('ReleaseCreation|e.g. eu-west-1-prod')"
              />
            </panel-form-field>
            <panel-form-field class="gl-grow" :label="s__('ContinuousDeployment|Tier')">
              <gl-collapsible-listbox
                v-model="tier"
                block
                data-testid="tier-listbox"
                :items="tierItems"
              />
            </panel-form-field>
          </div>
        </panel-form-group>
      </gl-form>

      <template #footer>
        <div class="gl-flex gl-justify-end gl-gap-3">
          <gl-button data-testid="cancel-button" @click="handleClose">
            {{ __('Cancel') }}
          </gl-button>
          <gl-button
            :loading="isSubmitting"
            :disabled="isSubmitting || !organization"
            variant="confirm"
            data-testid="submit-environment-button"
            @click="onSubmit"
          >
            {{ s__('ContinuousDeployment|Register environment') }}
          </gl-button>
        </div>
      </template>
    </dynamic-panel>
  </mounting-portal>
</template>
