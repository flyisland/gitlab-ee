<script>
import {
  GlAvatar,
  GlAvatarLink,
  GlButton,
  GlButtonGroup,
  GlIcon,
  GlLink,
  GlTableLite,
  GlToggle,
  GlTooltipDirective,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import FlowTriggerEventTokens from 'ee/ai/duo_agents_platform/components/common/flow_trigger_event_tokens.vue';
import { FLOW_TRIGGERS_EDIT_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';

const thClass = 'gl-whitespace-nowrap';
const truncateClasses = '@md/panel:gl-truncate @md/panel:gl-max-w-0 @md/panel:gl-whitespace-nowrap';

export default {
  name: 'FlowTriggersTable',
  components: {
    GlTableLite,
    GlButton,
    GlButtonGroup,
    GlIcon,
    GlAvatar,
    GlAvatarLink,
    GlLink,
    GlToggle,
    FlowTriggerEventTokens,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    aiFlowTriggers: {
      type: Array,
      required: true,
    },
    togglingIds: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  emits: ['delete-trigger', 'toggle-trigger'],
  methods: {
    createEditPath(id) {
      return { name: FLOW_TRIGGERS_EDIT_ROUTE, params: { id: getIdFromGraphQLId(id) } };
    },
    isToggling(id) {
      return this.togglingIds.includes(id);
    },
  },
  fields: [
    {
      key: 'description',
      label: s__('DuoAgentsPlatform|Description'),
      thClass,
      tdClass: truncateClasses,
      columnClass: 'gl-w-5/20',
    },
    {
      key: 'eventType',
      label: s__('DuoAgentsPlatform|Event'),
      thClass,
      columnClass: 'gl-w-4/20',
    },
    {
      key: 'configPath',
      label: s__('DuoAgentsPlatform|Target'),
      thClass,
      tdClass: truncateClasses,
      columnClass: 'gl-w-4/20',
    },
    {
      key: 'user',
      label: s__('DuoAgentsPlatform|Owner'),
      thClass,
      columnClass: 'gl-w-2/20',
    },
    {
      key: 'status',
      label: s__('DuoAgentsPlatform|Status'),
      thClass,
      columnClass: 'gl-w-2/20',
    },
    {
      key: 'actions',
      label: s__('DuoAgentsPlatform|Actions'),
      thClass: [thClass, 'gl-text-right'],
      columnClass: 'gl-w-3/20',
    },
  ],
};
</script>

<template>
  <gl-table-lite :fields="$options.fields" :items="aiFlowTriggers" stacked="md">
    <template #table-colgroup="{ fields }">
      <col v-for="field in fields" :key="field.key" :class="field.columnClass" />
    </template>

    <template #cell(description)="{ item }">
      <span class="gl-flex gl-justify-end @md/panel:gl-justify-start">
        <span class="gl-min-w-0 gl-truncate">
          {{ item.description }}
        </span>
      </span>
    </template>

    <template #cell(eventType)="{ item }">
      <flow-trigger-event-tokens
        class="gl-justify-end @md/panel:gl-justify-start"
        :flow-trigger="item"
      />
    </template>

    <template #cell(configPath)="{ item }">
      <gl-link
        v-if="item.configPath"
        v-gl-tooltip="item.configPath"
        data-testid="flow-trigger-config-path"
        :href="item.configUrl"
        class="gl-inline-flex gl-max-w-full gl-gap-2"
      >
        <gl-icon name="doc-text" class="gl-shrink-0 gl-text-subtle" />
        <span class="gl-truncate">
          {{ item.configPath.split('/').at(-1) }}
        </span>
      </gl-link>
      <span v-else-if="item.aiCatalogItemConsumer?.item" data-testid="flow-trigger-catalog-item">
        {{ item.aiCatalogItemConsumer.item.name }}
      </span>
      <span v-else data-testid="flow-trigger-config-path-fallback" class="gl-text-subtle">
        {{ s__('DuoAgentsPlatform|Unknown') }}
      </span>
    </template>

    <template #cell(user)="{ item }">
      <gl-avatar-link
        v-if="item.user"
        v-gl-tooltip
        :href="item.user.webPath"
        :title="item.user.username"
      >
        <gl-avatar :size="32" :src="item.user.avatarUrl" :alt="item.user.username" />
      </gl-avatar-link>
      <span v-else class="gl-text-subtle">
        {{ s__('DuoAgentsPlatform|Unknown') }}
      </span>
    </template>

    <template #cell(status)="{ item }">
      <gl-toggle
        class="gl-justify-end @md/panel:gl-justify-start"
        :value="item.active"
        :is-loading="isToggling(item.id)"
        :label="s__('DuoAgentsPlatform|Trigger active')"
        label-position="hidden"
        data-testid="flow-trigger-active-toggle"
        @change="(active) => $emit('toggle-trigger', { id: item.id, active })"
      />
    </template>

    <template #cell(actions)="{ item }">
      <div class="gl-flex gl-justify-end">
        <gl-button-group>
          <gl-button
            v-gl-tooltip
            :title="s__('DuoAgentsPlatform|Edit trigger')"
            :aria-label="s__('DuoAgentsPlatform|Edit trigger')"
            :to="createEditPath(item.id)"
            data-testid="flow-trigger-edit-action"
            icon="pencil"
          />
          <gl-button
            v-gl-tooltip
            :title="s__('DuoAgentsPlatform|Delete trigger')"
            :aria-label="s__('DuoAgentsPlatform|Delete trigger')"
            data-testid="flow-trigger-delete-action"
            icon="remove"
            variant="danger"
            @click="$emit('delete-trigger', item.id)"
          />
        </gl-button-group>
      </div>
    </template>
  </gl-table-lite>
</template>
