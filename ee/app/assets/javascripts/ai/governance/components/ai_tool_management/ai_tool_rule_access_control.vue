<script>
import {
  GlButton,
  GlCollapsibleListbox,
  GlIcon,
  GlLoadingIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { gql } from '@apollo/client/core';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import updateAiToolRuleMutation from '../../graphql/mutations/update_ai_tool_rule.mutation.graphql';

const ACCESS_OPTIONS = [
  {
    value: 'ALLOW',
    icon: 'check',
    text: s__('AiGovernance|Always allow'),
    iconClass: 'gl-text-green-500',
  },
  {
    value: 'ASK',
    icon: 'question-o',
    text: s__('AiGovernance|Always ask'),
    iconClass: null,
  },
  {
    value: 'DENY',
    icon: 'close',
    text: s__('AiGovernance|Always deny'),
    iconClass: 'gl-text-red-500',
  },
];

const ACCESS_OPTIONS_BY_VALUE = ACCESS_OPTIONS.reduce((acc, option) => {
  acc[option.value] = option;
  return acc;
}, {});

const ACCESS_RANK = { ALLOW: 0, ASK: 1, DENY: 2 };

const FLOOR_DISABLED_TOOLTIP = s__(
  'AiGovernance|Set at the group level. Projects can only apply stricter rules.',
);

const UPDATED_TOOL_RULE_FRAGMENT = gql`
  fragment UpdatedAiToolRule on AiToolRule {
    webAccess
    localAccess
  }
`;

export default {
  name: 'AiToolRuleAccessControl',
  components: {
    GlButton,
    GlCollapsibleListbox,
    GlIcon,
    GlLoadingIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    toolRule: {
      type: Object,
      required: true,
    },
    accessType: {
      type: String,
      required: true,
      validator: (value) => ['webAccess', 'localAccess'].includes(value),
    },
    groupFullPath: {
      type: String,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: false,
      default: '',
    },
    floorValue: {
      type: String,
      required: false,
      default: null,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    disabledTooltip: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      pendingValue: null,
    };
  },
  computed: {
    value() {
      return this.toolRule[this.accessType];
    },
    isLoading() {
      return this.pendingValue !== null;
    },
    selectedOption() {
      return ACCESS_OPTIONS_BY_VALUE[this.value];
    },
    accessOptions() {
      if (!this.floorValue) {
        return ACCESS_OPTIONS;
      }

      const floorRank = ACCESS_RANK[this.floorValue] ?? 0;

      return ACCESS_OPTIONS.map((option) => ({
        ...option,
        disabled: ACCESS_RANK[option.value] < floorRank,
      }));
    },
    availableOptions() {
      return this.accessOptions.filter((option) => !option.disabled);
    },
    isStatic() {
      return this.disabled || this.availableOptions.length <= 1;
    },
    staticTooltip() {
      if (!this.isStatic) return '';
      if (this.disabled) return this.disabledTooltip;
      if (this.floorValue) return FLOOR_DISABLED_TOOLTIP;
      return '';
    },
  },
  FLOOR_DISABLED_TOOLTIP,
  i18n: {
    updateError: s__('AiGovernance|Failed to update tool rule. Please try again.'),
  },
  methods: {
    handleSelect(newValue) {
      if (newValue === this.value || this.isLoading) return;
      this.updateRule(newValue);
    },
    async updateRule(newValue) {
      this.pendingValue = newValue;

      const input = {
        fullPath: this.groupFullPath,
        toolId: this.toolRule.id,
        [this.accessType]: newValue,
      };

      if (this.projectFullPath) {
        input.projectPath = this.projectFullPath;

        const otherAccessType = this.accessType === 'webAccess' ? 'localAccess' : 'webAccess';
        if (this.toolRule[otherAccessType]) {
          input[otherAccessType] = this.toolRule[otherAccessType];
        }
      }

      try {
        const { data } = await this.$apollo.mutate({
          mutation: updateAiToolRuleMutation,
          variables: { input },
        });

        if (data?.updateAiToolRule?.errors?.length > 0) {
          createAlert({ message: this.$options.i18n.updateError, captureError: true });
          return;
        }

        this.$apollo.getClient().writeFragment({
          id: `AiToolRule:${this.toolRule.id}`,
          fragment: UPDATED_TOOL_RULE_FRAGMENT,
          data: {
            __typename: 'AiToolRule',
            webAccess: data.updateAiToolRule.toolRule.webAccess,
            localAccess: data.updateAiToolRule.toolRule.localAccess,
          },
        });
      } catch {
        createAlert({ message: this.$options.i18n.updateError, captureError: true });
      } finally {
        this.pendingValue = null;
      }
    },
  },
};
</script>

<template>
  <span
    v-gl-tooltip="staticTooltip"
    class="gl-flex gl-w-full"
    :class="{ '!gl-pointer-events-auto': staticTooltip }"
  >
    <span
      v-if="isStatic"
      class="gl-flex gl-items-center gl-gap-2 gl-px-3 gl-py-2"
      data-testid="access-control-static"
    >
      <gl-icon
        v-if="selectedOption"
        :name="selectedOption.icon"
        :class="selectedOption.iconClass"
      />
      <span v-if="selectedOption" data-testid="access-control-static-text">
        {{ selectedOption.text }}
      </span>
    </span>

    <gl-collapsible-listbox
      v-else
      :items="accessOptions"
      :selected="value"
      :disabled="disabled || isLoading"
      block
      panel-match-trigger-width
      class="gl-w-full"
      data-testid="access-control-listbox"
      @select="handleSelect"
    >
      <template #toggle>
        <gl-button
          category="secondary"
          size="small"
          block
          button-text-classes="gl-flex gl-items-center gl-gap-2"
          :disabled="disabled || isLoading"
          :aria-label="selectedOption ? selectedOption.text : ''"
          data-testid="access-control-toggle"
        >
          <gl-loading-icon v-if="isLoading" size="sm" />
          <gl-icon
            v-else-if="selectedOption"
            :name="selectedOption.icon"
            :class="selectedOption.iconClass"
          />
          <span v-if="selectedOption" data-testid="access-control-toggle-text">
            {{ selectedOption.text }}
          </span>
          <gl-icon class="gl-ml-auto" name="chevron-down" />
        </gl-button>
      </template>
      <template #list-item="{ item }">
        <span
          v-gl-tooltip="item.disabled ? $options.FLOOR_DISABLED_TOOLTIP : ''"
          class="gl-flex gl-items-center gl-gap-3"
          :data-testid="`access-option-${item.value.toLowerCase()}`"
        >
          <gl-icon :name="item.icon" :class="item.iconClass" />
          {{ item.text }}
        </span>
      </template>
    </gl-collapsible-listbox>
  </span>
</template>
