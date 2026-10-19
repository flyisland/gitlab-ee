<script>
import { GlBadge, GlButton, GlIcon } from '@gitlab/ui';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import TriggerVariableTable from './trigger_variable_table.vue';

export default {
  name: 'ScanTriggersDetail',
  components: {
    CrudComponent,
    GlBadge,
    GlButton,
    GlIcon,
    TriggerVariableTable,
  },
  props: {
    profileHelpLink: {
      type: String,
      required: false,
      default: () => '',
    },
    triggers: {
      type: Array,
      required: true,
    },
    variableDefinitions: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      collapsed: true,
    };
  },
  methods: {
    variableRows(trigger) {
      return trigger.variableRows ?? [];
    },
  },
};
</script>

<template>
  <div>
    <crud-component
      v-for="trigger in triggers"
      :key="trigger.anchor"
      :is-collapsible="true"
      :collapsed="collapsed"
      :description="trigger.subtitle"
      :anchor-id="trigger.anchor"
      body-class="!gl-p-3"
      class="hover:!gl-bg-neutral-100 dark:hover:!gl-bg-neutral-800"
    >
      <template #title>
        <gl-icon v-if="trigger.icon" :name="trigger.icon" />
        {{ trigger.title }}
      </template>
      <template #actions>
        <gl-badge variant="success" icon="check-circle" class="gl-self-center">
          {{ s__('ScanProfiles|On') }}
        </gl-badge>
      </template>

      <p class="gl-mb-4">
        {{ trigger.description }}
      </p>

      <div v-if="trigger.targetBranch || trigger.scope || trigger.results" class="gl-mb-4">
        <p v-if="trigger.targetBranch" class="gl-m-0 gl-mb-1">
          <strong>{{ s__('ScanProfiles|Target branch:') }}</strong> {{ trigger.targetBranch }}
        </p>
        <p v-if="trigger.scope" class="gl-m-0 gl-mb-1">
          <strong>{{ s__('ScanProfiles|Scope:') }}</strong> {{ trigger.scope }}
        </p>
        <p v-if="trigger.results" class="gl-m-0 gl-mb-1">
          <strong>{{ s__('ScanProfiles|Results:') }}</strong> {{ trigger.results }}
        </p>
      </div>

      <trigger-variable-table
        v-if="variableRows(trigger).length"
        :trigger-title="trigger.title"
        :rows="variableRows(trigger)"
        :variable-definitions="variableDefinitions"
      />

      <gl-button
        v-if="trigger.helpLink || profileHelpLink"
        variant="default"
        size="small"
        icon="external-link"
        :href="trigger.helpLink || profileHelpLink"
        target="_blank"
      >
        {{ s__('ScanProfiles|View documentation') }}
      </gl-button>
    </crud-component>
  </div>
</template>
