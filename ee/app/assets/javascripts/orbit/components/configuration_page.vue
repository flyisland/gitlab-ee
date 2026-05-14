<script>
import { GlAvatar, GlBadge, GlTable, GlLink, GlIcon, GlToggle, GlLoadingIcon } from '@gitlab/ui';
import { createAlert } from '~/alert';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { s__, __ } from '~/locale';
import ownedNamespacesQuery from '../graphql/queries/owned_namespaces.query.graphql';
import orbitUpdateMutation from '../graphql/mutations/orbit_update.mutation.graphql';
import { fetchOrbitStatus, fetchOrbitTools } from '../api/orbit_api';
import { STATUS_HEALTHY, STATUS_UNKNOWN } from '../constants';
import ComponentHealthCard from './component_health_card.vue';
import ToolCard from './tool_card.vue';

const TOOL_SAMPLE_PROMPTS = {
  query_graph: s__('Orbit|What issues are blocking the login feature?'),
  get_graph_schema: s__('Orbit|What types of data are available?'),
  get_graph_entities: s__('Orbit|What types of data are available?'),
  expand_nodes: s__('Orbit|What details can I see about a merge request?'),
};

export default {
  name: 'OrbitConfiguration',
  compatConfig: { MODE: 3 },
  components: {
    GlAvatar,
    GlBadge,
    GlTable,
    GlLink,
    GlIcon,
    GlToggle,
    GlLoadingIcon,
    ComponentHealthCard,
    ToolCard,
  },
  apollo: {
    namespaces: {
      query: ownedNamespacesQuery,
      variables() {
        return { first: 25 };
      },
      update(data) {
        return data.groups?.nodes || [];
      },
      error() {
        createAlert({ message: s__('Orbit|Failed to load groups. Please try again.') });
      },
    },
  },
  data() {
    return {
      namespaces: [],
      togglingGroups: {},
      indexingGroups: {},
      status: {
        version: '-',
        overall: STATUS_UNKNOWN,
        components: [],
      },
      tools: [],
      statusLoading: true,
    };
  },
  computed: {
    namespacesLoading() {
      return this.$apollo.queries.namespaces.loading;
    },
    overallVariant() {
      return this.status.overall === STATUS_HEALTHY ? 'success' : 'danger';
    },
    overallLabel() {
      switch (this.status.overall) {
        case STATUS_HEALTHY:
          return s__('Orbit|Healthy');
        case STATUS_UNKNOWN:
          return s__('Orbit|No connection');
        default:
          return s__('Orbit|Unhealthy');
      }
    },
    showComponents() {
      return !this.statusLoading && this.status.components.length > 0;
    },
    indexFields() {
      return [
        { key: 'group', label: __('Group') },
        { key: 'path', label: __('Path') },
        { key: 'status', label: __('Status') },
        { key: 'enable', label: s__('Orbit|Enable') },
      ];
    },
    indexItems() {
      return this.namespaces.map((ns) => {
        const isIndexing = Boolean(this.indexingGroups[ns.fullPath]);
        let indexStatus;
        if (isIndexing) {
          indexStatus = s__('Orbit|Indexing…');
        } else if (ns.knowledgeGraphEnabled) {
          indexStatus = s__('Orbit|Indexed');
        } else {
          indexStatus = s__('Orbit|Not indexed');
        }

        return {
          ...ns,
          groupUrl: `/${ns.fullPath}`,
          groupName: ns.name,
          isIndexing,
          indexStatus,
        };
      });
    },
    toolsWithPrompts() {
      return this.tools.map((tool) => ({
        ...tool,
        samplePrompt: TOOL_SAMPLE_PROMPTS[tool.name] || '',
      }));
    },
  },
  mounted() {
    this.fetchStatus();
    this.fetchTools();
  },
  methods: {
    async fetchStatus() {
      try {
        const { data } = await fetchOrbitStatus();
        this.status = {
          version: data.version || '-',
          overall: data.status || STATUS_UNKNOWN,
          components: data.components || [],
        };
      } catch (error) {
        Sentry.captureException(error);
        createAlert({ message: s__('Orbit|Unable to load cluster status.') });
      } finally {
        this.statusLoading = false;
      }
    },
    async fetchTools() {
      try {
        const { data } = await fetchOrbitTools();
        this.tools = data || [];
      } catch (error) {
        Sentry.captureException(error);
      }
    },
    isToggling(fullPath) {
      return Boolean(this.togglingGroups[fullPath]);
    },
    statusIconClass(item) {
      if (item.isIndexing) return 'gl-text-subtle';
      if (item.knowledgeGraphEnabled) return 'gl-text-success';
      return 'gl-text-subtle';
    },
    statusIcon(item) {
      if (item.isIndexing) return 'hourglass';
      if (item.knowledgeGraphEnabled) return 'check';
      return 'dash';
    },
    async toggleNamespace(item, newValue) {
      this.togglingGroups = { ...this.togglingGroups, [item.fullPath]: true };

      try {
        const { data } = await this.$apollo.mutate({
          mutation: orbitUpdateMutation,
          variables: {
            input: {
              groupPath: item.fullPath,
              enabled: newValue,
            },
          },
        });

        const result = data.orbitUpdate;

        if (result.errors?.length) {
          throw new Error(result.errors.join(', '));
        }

        if (newValue) {
          this.indexingGroups = { ...this.indexingGroups, [item.fullPath]: true };
        } else {
          const { [item.fullPath]: _, ...rest } = this.indexingGroups;
          this.indexingGroups = rest;
        }

        await this.$apollo.queries.namespaces.refetch();
      } catch (error) {
        Sentry.captureException(error);
        createAlert({
          message: s__('Orbit|Failed to update group setting. Please try again.'),
        });
      } finally {
        const { [item.fullPath]: _, ...rest } = this.togglingGroups;
        this.togglingGroups = rest;
      }
    },
  },
};
</script>

<template>
  <div class="gl-pt-5">
    <h1 class="gl-my-0">{{ s__('Orbit|Configuration') }}</h1>

    <!-- Status Section -->
    <div
      class="gl-my-5 gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-subtle"
    >
      <div class="gl-bg-strong gl-p-5">
        <p class="gl-heading-3 gl-mb-3 gl-mt-0">{{ s__('Orbit|Status') }}</p>

        <gl-loading-icon v-if="statusLoading" size="sm" class="gl-my-5" />

        <div v-else class="gl-align-items-center gl-flex gl-gap-3">
          <gl-icon name="doc-text" :size="16" />
          <span
            >{{ s__('Orbit|Version') }} <code>{{ status.version }}</code></span
          >
          <gl-icon name="status-health" :size="16" />
          <span>{{ s__('Orbit|Overall status') }}</span>
          <gl-badge :variant="overallVariant">{{ overallLabel }}</gl-badge>
        </div>
      </div>

      <template v-if="showComponents">
        <div class="gl-p-5">
          <p class="gl-heading-4 gl-mb-3 gl-mt-0">
            {{ s__('Orbit|Components') }}
          </p>
          <div class="gl-flex gl-gap-3">
            <component-health-card
              v-for="component in status.components"
              :key="component.name"
              :component="component"
            />
          </div>
        </div>
      </template>
    </div>

    <!-- Settings Section -->
    <p class="gl-heading-3 gl-mb-3 gl-mt-0">{{ s__('Orbit|Settings') }}</p>
    <div
      class="gl-mb-5 gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-subtle"
    >
      <div class="gl-bg-strong gl-p-5">
        <p class="gl-heading-4 gl-mb-1 gl-mt-0">
          {{ s__('Orbit|Indexes') }}
        </p>
        <p class="gl-mb-0 gl-text-subtle">
          {{
            s__(
              'Orbit|Enable Orbit for a top-level group to index its projects and make them queryable',
            )
          }}
        </p>
      </div>

      <gl-loading-icon v-if="namespacesLoading" size="sm" class="gl-my-5" />

      <gl-table
        v-else
        :items="indexItems"
        :fields="indexFields"
        stacked="sm"
        :show-empty="false"
        borderless
        class="gl-mb-0"
      >
        <template #cell(group)="{ item }">
          <gl-link :href="item.groupUrl" class="gl-flex gl-items-center gl-gap-3">
            <gl-avatar
              :src="item.avatarUrl"
              :entity-name="item.groupName"
              :size="32"
              shape="rect"
            />
            {{ item.groupName }}
          </gl-link>
        </template>
        <template #cell(path)="{ item }">
          {{ item.fullPath }}
        </template>
        <template #cell(status)="{ item }">
          <span class="gl-flex gl-items-center gl-gap-2">
            <gl-loading-icon v-if="item.isIndexing" size="sm" inline />
            <gl-icon v-else :name="statusIcon(item)" :size="16" :class="statusIconClass(item)" />
            {{ item.indexStatus }}
          </span>
        </template>
        <template #cell(enable)="{ item }">
          <gl-loading-icon v-if="isToggling(item.fullPath)" size="sm" inline />
          <gl-toggle
            v-else
            :value="item.knowledgeGraphEnabled"
            :label="s__('Orbit|Enable')"
            label-position="hidden"
            @change="toggleNamespace(item, $event)"
          />
        </template>
      </gl-table>
    </div>

    <!-- Tools Section -->
    <div v-if="toolsWithPrompts.length">
      <p class="gl-heading-3 gl-mb-3 gl-mt-0">{{ s__('Orbit|Tools') }}</p>
      <div class="gl-flex gl-gap-3">
        <tool-card
          v-for="tool in toolsWithPrompts"
          :key="tool.name"
          :tool="tool"
          :sample-prompt="tool.samplePrompt"
        />
      </div>
    </div>
  </div>
</template>
