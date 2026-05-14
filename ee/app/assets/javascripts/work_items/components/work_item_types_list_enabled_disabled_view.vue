<script>
import { GlLoadingIcon, GlAlert, GlButton } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import WorkItemTypeIcon from '~/work_items/components/work_item_type_icon.vue';
import workItemTypesConfigurationQuery from '~/work_items/graphql/work_item_types_configuration.query.graphql';
import { n__, s__ } from '~/locale';

export default {
  name: 'WorkItemTypesListEnabledDisabledView',
  components: {
    CrudComponent,
    WorkItemTypeIcon,
    GlLoadingIcon,
    GlAlert,
    GlButton,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showDisabledTypes: false,
      errorMessage: '',
      workItemTypes: [],
    };
  },
  apollo: {
    workItemTypes: {
      query: workItemTypesConfigurationQuery,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data.namespace?.workItemTypes?.nodes;
      },
      error(error) {
        this.errorMessage = s__('WorkItem|Failed to fetch work item types.');
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    partitionedWorkItemTypes() {
      return (this.workItemTypes || []).reduce(
        (acc, item) => {
          acc[item.enabled === false ? 'disabled' : 'enabled'].push(item);
          return acc;
        },
        { enabled: [], disabled: [] },
      );
    },
    enabledWorkItemTypes() {
      return this.partitionedWorkItemTypes.enabled;
    },
    disabledWorkItemTypes() {
      return this.partitionedWorkItemTypes.disabled;
    },
    disabledTypesLabel() {
      const count = this.disabledWorkItemTypes.length;
      return n__('WorkItem|%d disabled type', 'WorkItem|%d disabled types', count);
    },
    isLoading() {
      return this.$apollo.queries.workItemTypes.loading;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorMessage" variant="danger" class="gl-mb-5">
      {{ errorMessage }}
    </gl-alert>

    <gl-loading-icon v-if="isLoading" size="lg" />
    <div v-else>
      <!-- Enabled Types Section -->
      <crud-component :title="s__('WorkItem|Enabled types')" title-tag="h3">
        <div class="-gl-my-4" data-testid="enabled-work-item-types-table">
          <div
            v-for="item in enabledWorkItemTypes"
            :key="item.id"
            class="gl-border-b gl-flex gl-justify-between gl-gap-4 gl-border-b-subtle gl-py-4 last:gl-border-b-0"
            :data-testid="`work-item-type-row-${item.id}`"
          >
            <!-- Type Column -->
            <div class="gl-flex gl-items-center gl-gap-2">
              <work-item-type-icon
                :work-item-type="item.name"
                :type-icon-name="item.iconName"
                class="gl-font-semibold gl-text-default"
                icon-class="gl-flex-shrink-0 gl-mr-2"
                show-text
                icon-variant="subtle"
              />
            </div>
          </div>
        </div>
      </crud-component>

      <!-- Disabled Types Section with Toggle Button -->
      <div v-if="disabledWorkItemTypes.length" class="gl-mt-6">
        <gl-button
          category="tertiary"
          size="small"
          class="gl-mb-3"
          data-testid="disabled-types-toggle-button"
          :icon="showDisabledTypes ? 'chevron-down' : 'chevron-right'"
          :aria-expanded="showDisabledTypes"
          @click="showDisabledTypes = !showDisabledTypes"
        >
          {{ disabledTypesLabel }}
        </gl-button>

        <crud-component
          v-if="showDisabledTypes"
          :title="s__('WorkItem|Disabled types')"
          :description="s__('WorkItem|Cannot be used to create new items.')"
        >
          <div class="-gl-my-4" data-testid="disabled-work-item-types-table">
            <div
              v-for="item in disabledWorkItemTypes"
              :key="item.id"
              class="gl-border-b gl-flex gl-justify-between gl-gap-4 gl-border-b-subtle gl-py-4 last:gl-border-b-0"
              :data-testid="`work-item-type-row-${item.id}`"
            >
              <!-- Type Column -->
              <div class="gl-flex gl-items-center gl-gap-2">
                <work-item-type-icon
                  :work-item-type="item.name"
                  :type-icon-name="item.iconName"
                  class="gl-font-semibold gl-text-default"
                  icon-class="gl-flex-shrink-0 gl-mr-2"
                  show-text
                  icon-variant="subtle"
                />
              </div>
            </div>
          </div>
        </crud-component>
      </div>
    </div>
  </div>
</template>
