<script>
import { GlAlert, GlButton, GlFormInput } from '@gitlab/ui';
import { produce } from 'immer';
import { MountingPortal } from 'portal-vue';
import { __, s__ } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import cdApplicationCreateMutation from '../graphql/cd_application_create.mutation.graphql';
import cdApplicationsQuery from '../graphql/cd_applications.query.graphql';
import PanelFormField from './shared/panel_form_field.vue';
import PanelFormGroup from './shared/panel_form_group.vue';

export default {
  name: 'NewApplicationPanel',
  components: {
    GlAlert,
    DynamicPanel,
    GlButton,
    GlFormInput,
    MountingPortal,
    PanelFormField,
    PanelFormGroup,
  },
  props: {
    open: {
      type: Boolean,
      required: true,
    },
    organizationId: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['close'],
  data() {
    return {
      errors: undefined,
      name: '',
      description: '',
      isSubmitting: false,
      serviceName: '',
      serviceDescription: '',
      serviceIndex: null,
      services: [],
      showServiceForm: false,
    };
  },
  computed: {
    serviceFormHeading() {
      return this.serviceIndex == null
        ? s__('ContinuousDeployment|Add service')
        : s__('ContinuousDeployment|Edit service');
    },
    serviceFormButton() {
      return this.serviceIndex == null
        ? s__('ContinuousDeployment|Add service')
        : s__('ContinuousDeployment|Save service');
    },
  },
  methods: {
    addService() {
      if (this.serviceIndex == null) {
        this.services.push({ name: this.serviceName, description: this.serviceDescription });
      } else {
        this.services[this.serviceIndex].name = this.serviceName;
        this.services[this.serviceIndex].description = this.serviceDescription;
      }
      this.showServiceForm = false;
      this.serviceName = '';
      this.serviceDescription = '';
      this.serviceIndex = null;
    },
    editService(index) {
      this.serviceIndex = index;
      this.serviceName = this.services[index].name;
      this.serviceDescription = this.services[index].description;
      this.showServiceForm = true;
    },
    removeService(index) {
      this.services.splice(index, 1);
    },
    closePanel() {
      this.$emit('close');
    },
    clearForm() {
      this.name = '';
      this.description = '';
      this.serviceName = '';
      this.serviceDescription = '';
      this.serviceIndex = null;
      this.services = [];
      this.errors = undefined;
    },
    async submitForm() {
      try {
        this.isSubmitting = true;

        const { data } = await this.$apollo.mutate({
          mutation: cdApplicationCreateMutation,
          variables: {
            input: {
              name: this.name,
              description: this.description,
              organizationId: this.organizationId,
              services: this.services,
            },
          },
          update: (cache, { data: { cdApplicationCreate } }) => {
            if (!cdApplicationCreate.application) {
              return;
            }
            const sourceData = cache.readQuery({ query: cdApplicationsQuery });
            cache.writeQuery({
              query: cdApplicationsQuery,
              data: produce(sourceData, (draftState) => {
                draftState.organization.cdApplications.nodes.push(cdApplicationCreate.application);
              }),
            });
          },
        });

        if (data.cdApplicationCreate.errors.length) {
          this.errors = data.cdApplicationCreate.errors;
          return;
        }

        this.clearForm();
        this.closePanel();
      } catch (error) {
        Sentry.captureException(error);
        this.errors = [__('An error occurred. Please try again.')];
      } finally {
        this.isSubmitting = false;
      }
    },
  },
};
</script>

<template>
  <mounting-portal v-if="open" mount-to="#contextual-panel-portal" append>
    <dynamic-panel @close="closePanel">
      <template #header>
        <div class="gl-py-3">
          <p
            class="gl-mb-2 gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-status-brand"
          >
            {{ s__('ContinuousDeployment|Add application') }}
          </p>
          <h3 class="gl-my-0 gl-text-base">
            {{ s__('ContinuousDeployment|Register application') }}
          </h3>
        </div>
      </template>

      <p class="gl-my-5 gl-text-subtle">
        {{
          s__(
            'ContinuousDeployment|Declare the topology of your application — services, environments, integrations — and Deploy will orchestrate rollouts for it.',
          )
        }}
      </p>

      <gl-alert v-if="errors" class="gl-my-4" variant="danger" @dismiss="errors = undefined">
        <ul class="gl-m-0 gl-pl-4">
          <li v-for="error in errors" :key="error">
            {{ error }}
          </li>
        </ul>
      </gl-alert>

      <panel-form-group
        :description="s__('ContinuousDeployment|A short name and description.')"
        step="1"
        :title="s__('ContinuousDeployment|Application identity')"
      >
        <div class="gl-flex gl-gap-3">
          <panel-form-field class="gl-grow" :label="s__('ContinuousDeployment|Application name')">
            <gl-form-input
              id="application-name"
              v-model="name"
              :placeholder="s__('ContinuousDeployment|e.g. acme-platform')"
            />
          </panel-form-field>
          <panel-form-field class="gl-grow" :label="s__('ContinuousDeployment|Description')">
            <gl-form-input
              id="application-description"
              v-model="description"
              :placeholder="s__('ContinuousDeployment|Brief description')"
            />
          </panel-form-field>
        </div>
      </panel-form-group>

      <panel-form-group
        class="gl-mt-4"
        :description="
          s__(
            'ContinuousDeployment|The deployable units. Each service has its own deployment strategy.',
          )
        "
        step="2"
        :title="s__('ContinuousDeployment|Services')"
      >
        <template #actions>
          <gl-button
            class="gl-shrink-0"
            category="secondary"
            :disabled="showServiceForm"
            variant="confirm"
            data-testid="add-service-header"
            @click="showServiceForm = true"
          >
            {{ s__('ContinuousDeployment|+ Add service') }}
          </gl-button>
        </template>
        <template v-if="services.length">
          <ul class="gl-m-0 gl-list-none gl-p-0" data-testid="services-list">
            <li
              v-for="(service, index) in services"
              :key="index"
              class="gl-border gl-mb-4 gl-flex gl-items-center gl-rounded-lg gl-px-4 gl-py-3"
            >
              <span class="gl-mr-auto gl-font-bold">{{ service.name }}</span>
              <gl-button
                category="tertiary"
                size="small"
                data-testid="edit-service"
                @click="editService(index)"
              >
                {{ s__('ContinuousDeployment|Edit') }}
              </gl-button>
              <gl-button
                category="tertiary"
                size="small"
                variant="danger"
                data-testid="remove-service"
                @click="removeService(index)"
              >
                {{ s__('ContinuousDeployment|Remove') }}
              </gl-button>
            </li>
          </ul>
        </template>
        <div
          v-else-if="!showServiceForm"
          class="gl-border gl-mb-4 gl-rounded-lg gl-border-dashed gl-bg-subtle gl-px-4 gl-py-3 gl-text-sm gl-text-subtle"
          data-testid="service-empty-state"
        >
          {{
            s__(
              'ContinuousDeployment|No services yet. Add at least one — a service is the deployable unit (Git repo with K8s manifests, or a container image).',
            )
          }}
        </div>
        <div
          v-if="showServiceForm"
          class="gl-border gl-rounded-lg gl-border-purple-100 gl-bg-purple-50 gl-px-4 gl-py-3"
          data-testid="service-form"
        >
          <span class="gl-text-sm gl-font-bold gl-uppercase gl-tracking-wide gl-text-purple-500">
            {{ serviceFormHeading }}
          </span>
          <div class="gl-mt-3 gl-flex gl-gap-3">
            <panel-form-field class="gl-grow" :label="s__('ContinuousDeployment|Service name')">
              <gl-form-input
                id="service-name"
                v-model="serviceName"
                :placeholder="s__('ContinuousDeployment|e.g. api-gateway')"
              />
            </panel-form-field>
            <panel-form-field class="gl-grow" :label="s__('ContinuousDeployment|Description')">
              <gl-form-input
                id="service-description"
                v-model="serviceDescription"
                :placeholder="s__('ContinuousDeployment|Brief description')"
              />
            </panel-form-field>
          </div>
          <div class="gl-flex gl-justify-end">
            <gl-button
              category="tertiary"
              data-testid="cancel-service"
              @click="showServiceForm = false"
            >
              {{ s__('ContinuousDeployment|Cancel') }}
            </gl-button>
            <gl-button variant="confirm" data-testid="add-service" @click="addService">
              {{ serviceFormButton }}
            </gl-button>
          </div>
        </div>
        <button
          v-else
          class="gl-border gl-w-full gl-rounded-lg gl-border-dashed gl-border-neutral-800 gl-bg-transparent gl-py-3 gl-text-sm"
          data-testid="add-another-service"
          @click="showServiceForm = true"
        >
          {{ s__('ContinuousDeployment|+ Add another service') }}
        </button>
      </panel-form-group>

      <template #footer>
        <div class="gl-flex gl-justify-end gl-gap-3">
          <gl-button data-testid="cancel-button" @click="closePanel">
            {{ __('Cancel') }}
          </gl-button>
          <gl-button
            :loading="isSubmitting"
            variant="confirm"
            data-testid="register-button"
            @click="submitForm"
          >
            {{ s__('ContinuousDeployment|Register application') }}
          </gl-button>
        </div>
      </template>
    </dynamic-panel>
  </mounting-portal>
</template>
