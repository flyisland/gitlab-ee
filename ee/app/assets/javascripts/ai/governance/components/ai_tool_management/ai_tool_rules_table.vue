<script>
import {
  GlAlert,
  GlBadge,
  GlKeysetPagination,
  GlLoadingIcon,
  GlTable,
  GlTruncate,
  GlTooltipDirective,
} from '@gitlab/ui';
import { gql } from '@apollo/client/core';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import getAiToolRulesQuery from '../../graphql/queries/get_ai_tool_rules.query.graphql';
import updateAiToolRuleMutation from '../../graphql/mutations/update_ai_tool_rule.mutation.graphql';
import AiToolRuleAccessControl from './ai_tool_rule_access_control.vue';

const DEFAULT_PAGE_SIZE = 20;

export default {
  name: 'AiToolRulesTable',
  components: {
    GlAlert,
    GlBadge,
    GlKeysetPagination,
    GlLoadingIcon,
    GlTable,
    GlTruncate,
    AiToolRuleAccessControl,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['groupFullPath'],
  apollo: {
    aiToolRules: {
      query: getAiToolRulesQuery,
      variables() {
        return {
          fullPath: this.groupFullPath,
          last: this.before ? DEFAULT_PAGE_SIZE : null,
          first: this.before ? null : DEFAULT_PAGE_SIZE,
          after: this.after,
          before: this.before,
        };
      },
      update(data) {
        this.hasError = false;
        return data.aiToolRules;
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      aiToolRules: null,
      after: null,
      before: null,
      hasError: false,
      loadingKeys: new Set(),
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.aiToolRules.loading;
    },
    items() {
      return this.aiToolRules?.nodes || [];
    },
    pageInfo() {
      return this.aiToolRules?.pageInfo || {};
    },
  },
  fields: [
    {
      key: 'name',
      label: s__('AiGovernance|Tool name'),
      thClass: 'gl-w-4/12',
    },
    {
      key: 'source',
      label: s__('AiGovernance|Source'),
      thClass: 'gl-w-1/12 gl-hidden @lg/panel:!gl-table-cell',
      tdClass: 'gl-whitespace-nowrap gl-hidden @lg/panel:!gl-table-cell',
    },
    {
      key: 'actionType',
      label: s__('AiGovernance|Action'),
      thClass: 'gl-w-1/12',
      tdClass: 'gl-whitespace-nowrap',
    },
    {
      key: 'category',
      label: s__('AiGovernance|Category'),
      thClass: 'gl-w-2/12',
      tdClass: 'gl-whitespace-nowrap',
    },
    {
      key: 'webAccess',
      label: s__('AiGovernance|Web access'),
      thClass: 'gl-w-2/12',
      tdClass: 'gl-whitespace-nowrap',
    },
    {
      key: 'localAccess',
      label: s__('AiGovernance|Local access'),
      thClass: 'gl-w-2/12',
      tdClass: 'gl-whitespace-nowrap',
    },
  ],
  i18n: {
    localAccessNotEnforced: s__('AiGovernance|Local access is not currently enforced.'),
    updateError: s__('AiGovernance|Failed to update tool rule. Please try again.'),
  },
  methods: {
    actionTypeBadgeVariant(actionType) {
      const variants = { READ: 'info', WRITE: 'warning', DESTROY: 'danger' };
      return variants[actionType] ?? 'neutral';
    },
    handleNext(endCursor) {
      this.after = endCursor;
      this.before = null;
    },
    handlePrev(startCursor) {
      this.before = startCursor;
      this.after = null;
    },
    isRuleLoading(itemId, accessType) {
      return this.loadingKeys.has(`${itemId}:${accessType}`);
    },
    async updateRule(item, accessType, newValue) {
      const key = `${item.id}:${accessType}`;
      this.loadingKeys = new Set([...this.loadingKeys, key]);

      try {
        const { data } = await this.$apollo.mutate({
          mutation: updateAiToolRuleMutation,
          variables: {
            input: {
              toolId: item.id,
              webAccess: accessType === 'webAccess' ? newValue : item.webAccess,
              localAccess: accessType === 'localAccess' ? newValue : item.localAccess,
            },
          },
        });

        if (data?.updateAiToolRule?.errors?.length > 0) {
          createAlert({ message: this.$options.i18n.updateError, captureError: true });
        } else {
          this.$apollo.getClient().writeFragment({
            id: `AiToolRule:${item.id}`,
            fragment: gql`
              fragment UpdatedAiToolRule on AiToolRule {
                webAccess
                localAccess
              }
            `,
            data: {
              webAccess: data.updateAiToolRule.webAccess,
              localAccess: data.updateAiToolRule.localAccess,
            },
          });
        }
      } catch {
        createAlert({ message: this.$options.i18n.updateError, captureError: true });
      } finally {
        this.loadingKeys = new Set([...this.loadingKeys].filter((k) => k !== key));
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="hasError" variant="danger" :dismissible="false" class="gl-mb-5">
      {{ s__('AiGovernance|Failed to load tool rules.') }}
    </gl-alert>

    <gl-table
      :fields="$options.fields"
      :items="items"
      :busy="isLoading"
      show-empty
      stacked="md"
      :tbody-tr-attr="{ 'data-testid': 'ai-tool-rule-row' }"
    >
      <template #table-busy>
        <gl-loading-icon size="lg" class="gl-my-5" />
      </template>

      <template #empty>
        <div class="gl-py-5 gl-text-center" data-testid="ai-tool-rules-empty">
          {{ s__('AiGovernance|No tool rules found.') }}
        </div>
      </template>

      <template #cell(name)="{ item }">
        <gl-truncate
          :text="item.name"
          class="gl-min-w-0 gl-max-w-full gl-font-monospace"
          with-tooltip
          data-testid="tool-name"
        />
      </template>

      <template #cell(source)="{ item }">
        <gl-truncate
          :text="item.source"
          class="gl-min-w-0 gl-max-w-full"
          with-tooltip
          data-testid="tool-source"
        />
      </template>

      <template #cell(actionType)="{ item }">
        <gl-badge :variant="actionTypeBadgeVariant(item.actionType)" data-testid="tool-action-type">
          {{ item.actionType }}
        </gl-badge>
      </template>

      <template #cell(category)="{ item }">
        <gl-truncate
          :text="item.category"
          class="gl-min-w-0 gl-max-w-full"
          with-tooltip
          data-testid="tool-category"
        />
      </template>

      <template #cell(webAccess)="{ item }">
        <ai-tool-rule-access-control
          :value="item.webAccess"
          :is-loading="isRuleLoading(item.id, 'webAccess')"
          data-testid="tool-web-access-control"
          @select="updateRule(item, 'webAccess', $event)"
        />
      </template>

      <template #cell(localAccess)="{ item }">
        <ai-tool-rule-access-control
          :value="item.localAccess"
          :is-loading="isRuleLoading(item.id, 'localAccess')"
          data-testid="tool-local-access-control"
          @select="updateRule(item, 'localAccess', $event)"
        />
      </template>

      <template #head(localAccess)="{ label }">
        <span v-gl-tooltip="$options.i18n.localAccessNotEnforced">{{ label }}</span>
      </template>
    </gl-table>

    <div
      v-if="pageInfo.hasNextPage || pageInfo.hasPreviousPage"
      class="gl-mt-5 gl-flex gl-justify-center"
    >
      <gl-keyset-pagination v-bind="pageInfo" @prev="handlePrev" @next="handleNext" />
    </div>
  </div>
</template>
