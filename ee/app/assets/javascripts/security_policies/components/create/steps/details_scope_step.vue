<script>
import { GlButton, GlFormGroup, GlFormInput, GlFormTextarea, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import EnforcementModeSelector from '../enforcement_mode_selector.vue';

export default {
  name: 'DetailsScopeStep',
  components: {
    GlButton,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlIcon,
    EnforcementModeSelector,
  },
  i18n: {
    policyName: s__('SecurityOrchestration|Policy Name'),
    policyNamePlaceholder: s__('SecurityOrchestration|e.g., Critical Vulnerability Block'),
    description: s__('SecurityOrchestration|Description'),
    descriptionPlaceholder: s__('SecurityOrchestration|Describe what this policy does...'),
    enforcementMode: s__('SecurityOrchestration|Enforcement Mode'),
    scope: s__('SecurityOrchestration|Scope'),
    targeting: s__('SecurityOrchestration|Targeting'),
    allProjects: s__('SecurityOrchestration|All projects'),
    targeted: s__('SecurityOrchestration|Targeted'),
    appliesToAll: s__('SecurityOrchestration|Applies to all'),
    projectsInNamespace: s__('SecurityOrchestration|projects in this namespace'),
    addScopeCondition: s__('SecurityOrchestration|Add scope condition'),
    estimated: s__('SecurityOrchestration|Estimated'),
    projectsAffected: s__('SecurityOrchestration|projects affected'),
    policiesFollow: s__('SecurityOrchestration|Policies follow a'),
    triggerRulesActions: s__('SecurityOrchestration|Trigger → Rules → Actions'),
    structureDescription: s__(
      'SecurityOrchestration|structure. Define when the policy evaluates, what conditions it checks, and what happens when conditions are met.',
    ),
    cancel: s__('SecurityOrchestration|Cancel'),
    next: s__('SecurityOrchestration|Next'),
  },
  props: {
    value: {
      type: Object,
      required: true,
    },
    projectCount: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  emits: ['input', 'next', 'cancel'],
  data() {
    return {
      localName: this.value.name || '',
      localDescription: this.value.description || '',
      localEnforcementMode: this.value.enforcementMode || 'enforce',
      localScope: this.value.scope || 'all',
      scopeConditionTypes: [
        s__('SecurityOrchestration|Attributes'),
        s__('SecurityOrchestration|Compliance Frameworks'),
        s__('SecurityOrchestration|Groups'),
        s__('SecurityOrchestration|Projects'),
      ],
    };
  },
  methods: {
    onNameInput(val) {
      this.localName = val;
      this.emitCurrent();
    },
    onDescriptionInput(val) {
      this.localDescription = val;
      this.emitCurrent();
    },
    onEnforcementModeChange(val) {
      this.localEnforcementMode = val;
      this.emitCurrent();
    },
    selectScope(id) {
      this.localScope = id;
      this.emitCurrent();
    },
    emitCurrent() {
      this.$emit('input', {
        name: this.localName,
        description: this.localDescription,
        enforcementMode: this.localEnforcementMode,
        scope: this.localScope,
      });
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-5">
    <gl-form-group :label="$options.i18n.policyName" label-for="policy-name">
      <gl-form-input
        id="policy-name"
        :value="localName"
        :placeholder="$options.i18n.policyNamePlaceholder"
        @input="onNameInput"
      />
    </gl-form-group>

    <gl-form-group :label="$options.i18n.description" label-for="policy-description" optional>
      <gl-form-textarea
        id="policy-description"
        :value="localDescription"
        :placeholder="$options.i18n.descriptionPlaceholder"
        @input="onDescriptionInput"
      />
    </gl-form-group>

    <div>
      <p class="gl-mb-3 gl-font-bold">{{ $options.i18n.enforcementMode }}</p>
      <enforcement-mode-selector :value="localEnforcementMode" @input="onEnforcementModeChange" />
    </div>

    <div>
      <p class="gl-mb-3 gl-font-bold">{{ $options.i18n.scope }}</p>
      <div class="gl-mb-1 gl-text-sm gl-text-secondary">{{ $options.i18n.targeting }}</div>
      <div class="gl-mb-4 gl-flex gl-gap-2">
        <gl-button
          :variant="localScope === 'all' ? 'confirm' : 'default'"
          @click="selectScope('all')"
        >
          <gl-icon name="group" class="gl-mr-2" />{{ $options.i18n.allProjects }} ({{
            projectCount
          }})
        </gl-button>
        <gl-button
          :variant="localScope === 'targeted' ? 'confirm' : 'default'"
          @click="selectScope('targeted')"
        >
          <gl-icon name="filter" class="gl-mr-2" />{{ $options.i18n.targeted }}
        </gl-button>
      </div>

      <template v-if="localScope === 'all'">
        <p class="gl-mb-0 gl-text-sm gl-text-secondary">
          {{ $options.i18n.appliesToAll }} <strong>{{ projectCount }}</strong>
          {{ $options.i18n.projectsInNamespace }}
        </p>
      </template>

      <template v-if="localScope === 'targeted'">
        <p class="gl-mb-2 gl-text-sm gl-font-bold">{{ $options.i18n.addScopeCondition }}</p>
        <div class="gl-mb-4 gl-flex gl-flex-wrap gl-gap-2">
          <gl-button
            v-for="condType in scopeConditionTypes"
            :key="condType"
            size="small"
            variant="default"
            >{{ condType }}</gl-button
          >
        </div>
        <p class="gl-mb-0 gl-text-sm gl-text-secondary">
          {{ $options.i18n.estimated }} <strong>{{ projectCount }}</strong>
          {{ $options.i18n.projectsAffected }}
        </p>
      </template>
    </div>

    <div class="gl-flex gl-items-center gl-gap-2 gl-rounded-base gl-bg-subtle gl-p-4">
      <gl-icon name="information-o" class="gl-text-secondary" />
      <p class="gl-mb-0 gl-text-sm gl-text-secondary">
        {{ $options.i18n.policiesFollow }} <strong>{{ $options.i18n.triggerRulesActions }}</strong>
        {{ $options.i18n.structureDescription }}
      </p>
    </div>

    <div class="gl-mt-4 gl-flex gl-justify-between">
      <gl-button @click="$emit('cancel')">{{ $options.i18n.cancel }}</gl-button>
      <gl-button variant="confirm" :disabled="!localName" @click="$emit('next')">{{
        $options.i18n.next
      }}</gl-button>
    </div>
  </div>
</template>
