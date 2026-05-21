<script>
import { uniqueId } from 'lodash-es';
import {
  GlAlert,
  GlForm,
  GlFormCheckbox,
  GlFormCheckboxGroup,
  GlFormGroup,
  GlModal,
  GlSprintf,
} from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { __, s__, sprintf } from '~/locale';
import { TYPENAME_PROJECT } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { FLOW_TRIGGER_TYPES } from 'ee/ai/duo_agents_platform/constants';
import {
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  AI_CATALOG_ITEM_LABELS,
  AI_CATALOG_PROJECT_CONSUMER_LABEL_DESCRIPTION,
} from '../constants';
import FormProjectDropdown from './form_project_dropdown.vue';
import AiCatalogItemConsumerWarning from './ai_catalog_item_consumer_warning.vue';

export default {
  name: 'AiCatalogItemConsumerModal',
  formId: uniqueId('ai-catalog-item-consumer-form-'),
  components: {
    FormProjectDropdown,
    GlAlert,
    GlForm,
    GlFormCheckbox,
    GlFormCheckboxGroup,
    GlFormGroup,
    GlModal,
    GlSprintf,
    AiCatalogItemConsumerWarning,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    isProjectNamespace: {},
    contextProjectId: {
      from: 'projectId',
      default: null,
    },
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    open: {
      type: Boolean,
      required: false,
      default: false,
    },
    modalId: {
      type: String,
      required: false,
      default: 'add-item-consumer-modal',
    },
    canEnable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['hide', 'submit'],
  data() {
    return {
      isOpen: this.open,
      projectId: null,
      isDirty: false,
      error: null,
      triggerTypes: [],
      mountedAt: null,
    };
  },
  computed: {
    defaultProjectId() {
      if (this.isProjectNamespace) {
        return convertToGraphQLId(TYPENAME_PROJECT, this.contextProjectId);
      }
      return this.item.public ? null : this.item.project?.id;
    },
    showProjectSection() {
      return !this.isProjectNamespace;
    },
    modal() {
      return {
        actionPrimary: {
          text: __('Enable'),
          attributes: {
            variant: 'confirm',
            type: 'submit',
            form: this.$options.formId,
            disabled: !this.canEnable,
          },
        },
        actionCancel: {
          text: __('Cancel'),
        },
      };
    },
    itemTypeLabel() {
      return AI_CATALOG_ITEM_LABELS[this.item.itemType];
    },
    title() {
      return sprintf(s__('AICatalog|Enable %{itemType} in your project'), {
        itemType: this.itemTypeLabel,
      });
    },
    projectLabelDescription() {
      return AI_CATALOG_PROJECT_CONSUMER_LABEL_DESCRIPTION[this.item.itemType];
    },
    isProjectValid() {
      return !this.isDirty || Boolean(this.projectId);
    },
    showStaticFields() {
      return !this.item.public;
    },
    isFormValid() {
      return this.isProjectValid && this.isTriggersValid;
    },
    availableFlowTriggerTypes() {
      return FLOW_TRIGGER_TYPES.filter(
        (type) => this.glFeatures.aiFlowTriggerPipelineHooks || type.value !== 'pipeline_hooks',
      );
    },
    isFoundationalFlow() {
      return this.item.itemType === AI_CATALOG_TYPE_FLOW && this.item.foundational;
    },
    showTriggers() {
      if (this.isFoundationalFlow) {
        return false;
      }
      return [AI_CATALOG_TYPE_FLOW, AI_CATALOG_TYPE_THIRD_PARTY_FLOW].includes(this.item.itemType);
    },
    triggersLabelDescription() {
      return sprintf(
        s__(
          'AICatalog|Choose what events in this project trigger the %{itemType}. You can change this later.',
        ),
        { itemType: this.itemTypeLabel },
      );
    },
    isTriggersValid() {
      return !this.showTriggers || !this.isDirty || this.triggerTypes.length > 0;
    },
    dropdownItemId() {
      return this.glFeatures.aiCatalogFilterEnabledProjects ? this.item.id : null;
    },
  },
  watch: {
    defaultProjectId(newVal) {
      if (this.projectId == null && newVal) {
        this.projectId = newVal;
        Sentry.captureException(
          new Error('AiCatalogItemConsumerModal: project data arrived after mount'),
          {
            level: 'info',
            tags: {
              race_type: 'ai_catalog_project_field',
              item_type: this.item?.itemType,
            },
            extra: {
              item_id: this.item?.id,
              time_to_resolve_ms:
                this.mountedAt != null ? Math.round(performance.now() - this.mountedAt) : null,
            },
          },
        );
      }
    },
  },
  mounted() {
    this.mountedAt = performance.now();
    this.resetForm();
  },
  methods: {
    onError(error) {
      this.error = error;
    },
    handleSubmit() {
      this.isDirty = true;
      if (!this.isFormValid) {
        return;
      }
      this.isOpen = false;
      this.isDirty = false;

      this.$emit('submit', {
        target: { projectId: this.projectId },
        ...(this.showTriggers ? { triggerTypes: this.triggerTypes } : {}),
      });
    },
    resetForm() {
      this.projectId = this.defaultProjectId;
      this.isDirty = false;
      this.error = null;
      this.triggerTypes = this.availableFlowTriggerTypes.map((type) => type.value);
    },
    onHidden() {
      this.resetForm();
      this.$emit('hide');
    },
  },
};
</script>

<template>
  <gl-modal
    v-model="isOpen"
    :modal-id="modalId"
    :title="title"
    :action-primary="modal.actionPrimary"
    :action-cancel="modal.actionCancel"
    @primary.prevent
    @hidden="onHidden"
  >
    <gl-alert
      v-if="error"
      data-testid="error-alert"
      variant="danger"
      class="gl-mb-5"
      @dismiss="error = null"
    >
      {{ error }}
    </gl-alert>

    <gl-alert
      v-if="!item.public && !isProjectNamespace && item.project"
      data-testid="private-alert"
      :dismissible="false"
      variant="info"
      class="gl-mb-5"
    >
      <gl-sprintf
        :message="
          s__(
            'AICatalog|This %{itemType} is private and can only be enabled in the project it was created in or its top-level group. Duplicate the agent to use the same configuration in other projects.',
          )
        "
      >
        <template #itemType>{{ itemTypeLabel }}</template>
      </gl-sprintf>
    </gl-alert>

    <dl>
      <dt class="gl-mb-2 gl-font-bold">
        <gl-sprintf :message="s__('AICatalog|Selected %{itemType}')">
          <template #itemType>{{ itemTypeLabel }}</template>
        </gl-sprintf>
      </dt>
      <dd class="gl-break-all">{{ item.name }}</dd>
    </dl>

    <gl-form :id="$options.formId" @submit.prevent="handleSubmit">
      <template v-if="showProjectSection">
        <div v-if="showStaticFields && item.project">
          <dl>
            <dt class="gl-mb-2 gl-font-bold">{{ __('Project') }}</dt>
            <dd data-testid="project-name">{{ item.project.nameWithNamespace }}</dd>
          </dl>
        </div>
        <div v-else>
          <gl-form-group
            :label="__('Project')"
            :label-description="projectLabelDescription"
            label-for="project-id"
            :state="isProjectValid"
            :invalid-feedback="s__('AICatalog|Project is required.')"
          >
            <form-project-dropdown
              id="project-id"
              v-model="projectId"
              data-testid="project-dropdown"
              :disabled="!canEnable"
              :is-valid="isProjectValid"
              :item-id="dropdownItemId"
              @error="onError"
            />
          </gl-form-group>
        </div>
      </template>
      <gl-form-group
        v-if="showTriggers && canEnable"
        :label="s__('AICatalog|Add triggers')"
        :label-description="triggersLabelDescription"
        label-for="flow-triggers"
        :state="isTriggersValid"
        :invalid-feedback="s__('AICatalog|Select at least one trigger.')"
      >
        <gl-form-checkbox-group id="flow-triggers" v-model="triggerTypes">
          <gl-form-checkbox
            v-for="triggerType in availableFlowTriggerTypes"
            :key="triggerType.value"
            :value="triggerType.value"
          >
            {{ triggerType.text }}
            <template #help>{{ triggerType.createHelp(itemTypeLabel) }}</template>
          </gl-form-checkbox>
        </gl-form-checkbox-group>
      </gl-form-group>
    </gl-form>
    <ai-catalog-item-consumer-warning :item-type="item.itemType" :can-enable="canEnable" />
  </gl-modal>
</template>
