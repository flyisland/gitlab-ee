<script>
import { defineComponent } from 'vue';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { fetchOrbitSchema } from 'ee/orbit/api/orbit_api';
import { fetchCombinedGraphStats } from 'ee/orbit/utils/graph_stats';
import { ENABLED_MEMBER_NAMESPACES_LIMIT } from 'ee/orbit/utils/namespace_limits';
import { ORBIT_ERROR_KIND, orbitErrorKind } from 'ee/orbit/utils/orbit_errors';
import { ROUTE_OVERVIEW } from '../constants';
import { normalizeSchema } from './schema_graph';
import SchemaDataTab from './schema_data_tab.vue';

export default defineComponent({
  name: 'OrbitSchemaPage',
  compatConfig: { MODE: 3 },
  components: { GlAlert, GlLoadingIcon, SchemaDataTab },
  inject: ['enabledMemberGroups'],
  data() {
    return {
      schema: null,
      isLoadingSchema: true,
      hasSchemaError: false,
      graphStats: null,
    };
  },
  computed: {
    initialEntity() {
      const { entity } = this.$route.query;
      return Array.isArray(entity) ? entity[0] : entity;
    },
    limitedEnabledMemberGroups() {
      return this.enabledMemberGroups.slice(0, ENABLED_MEMBER_NAMESPACES_LIMIT);
    },
    graphStatsByType() {
      return this.graphStats?.getEntityCounts() ?? null;
    },
  },
  watch: {
    enabledMemberGroups: {
      handler() {
        this.loadGraphStats();
      },
      immediate: true,
    },
  },
  mounted() {
    this.loadSchema();
  },
  methods: {
    async loadSchema() {
      this.isLoadingSchema = true;
      this.hasSchemaError = false;
      try {
        const { data } = await fetchOrbitSchema({ expand: '*' });
        this.schema = normalizeSchema(data);
      } catch (error) {
        Sentry.captureException(error);
        this.hasSchemaError = true;
      } finally {
        this.isLoadingSchema = false;
      }
    },
    onShowInstances({ entityType } = {}) {
      this.$router.push({
        name: ROUTE_OVERVIEW,
        query: entityType ? { entity: entityType } : {},
      });
    },
    async loadGraphStats() {
      if (!this.limitedEnabledMemberGroups.length) {
        this.graphStats = null;
        return;
      }

      // Like the Overview card: a partial sum would read as the real count.
      try {
        this.graphStats = await fetchCombinedGraphStats(this.limitedEnabledMemberGroups, {
          strict: true,
        });
      } catch (error) {
        if (orbitErrorKind(error) === ORBIT_ERROR_KIND.SERVER) Sentry.captureException(error);
        this.graphStats = null;
      }
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-min-h-0 gl-flex-1 gl-flex-col gl-pt-3" data-testid="orbit-schema-page">
    <gl-loading-icon v-if="isLoadingSchema" size="lg" class="gl-my-6" />
    <gl-alert
      v-else-if="hasSchemaError"
      variant="danger"
      :dismissible="false"
      :primary-button-text="__('Try again')"
      data-testid="schema-load-error"
      @primary-action="loadSchema"
    >
      {{ s__('Orbit|Unable to load Orbit schema. Please try again.') }}
    </gl-alert>
    <schema-data-tab
      v-else
      :schema="schema"
      :graph-stats="graphStatsByType"
      :initial-entity="initialEntity"
      @show-instances="onShowInstances"
    />
  </div>
</template>
