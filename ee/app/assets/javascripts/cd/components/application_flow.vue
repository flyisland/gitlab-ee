<script>
import { GlAlert, GlBadge, GlButton, GlLoadingIcon } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import cdApplicationFlowQuery from '../graphql/cd_application_flow.query.graphql';

export default {
  name: 'ApplicationFlow',
  components: {
    GlAlert,
    GlBadge,
    GlButton,
    GlLoadingIcon,
  },
  props: {
    applicationId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      flowDefinitions: [],
      hasError: false,
    };
  },
  apollo: {
    flowDefinitions: {
      query: cdApplicationFlowQuery,
      variables() {
        return { applicationId: this.applicationId };
      },
      update(data) {
        return data?.organization?.cdApplication?.applicationFlowDefinitions?.nodes ?? [];
      },
      error() {
        this.hasError = true;
      },
      watchLoading(isLoading) {
        if (isLoading) {
          this.hasError = false;
        }
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.flowDefinitions.loading;
    },
    hasFlow() {
      return this.flowDefinitions.length > 0;
    },
    version() {
      return this.flowDefinitions[0]?.version;
    },
    versionLabel() {
      return sprintf(s__('FlowEditor|Version %{version}'), { version: this.version });
    },
    latestDefinition() {
      return this.flowDefinitions[0]?.definition ?? '';
    },
    flowEditorRoute() {
      return {
        name: 'flow_editor_route',
        params: { id: String(getIdFromGraphQLId(this.applicationId)) },
      };
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" />

    <gl-alert v-else-if="hasError" variant="danger" :dismissible="false">
      {{ s__('FlowEditor|Failed to load the application flow. Refresh to try again.') }}
    </gl-alert>

    <div
      v-else
      class="gl-rounded-2xl gl-border-1 gl-border-solid gl-border-default gl-bg-subtle gl-p-3"
    >
      <template v-if="hasFlow">
        <div class="gl-mb-3 gl-flex gl-items-center gl-justify-between">
          <gl-badge variant="neutral">{{ versionLabel }}</gl-badge>
          <gl-button
            size="small"
            category="secondary"
            variant="default"
            icon="pencil"
            :to="flowEditorRoute"
            data-testid="edit-flow-button"
          >
            {{ s__('FlowEditor|Edit flow') }}
          </gl-button>
        </div>

        <pre
          class="gl-mb-0 gl-overflow-auto gl-border-none gl-text-sm"
          data-testid="flow-definition"
          >{{ latestDefinition }}</pre
        >
      </template>

      <div
        v-else
        class="gl-flex gl-flex-col gl-items-center gl-justify-center gl-gap-3 gl-py-6 gl-text-center"
      >
        <p class="gl-mb-0 gl-text-subtle">
          {{ s__('FlowEditor|No flow is defined for this application yet.') }}
        </p>
        <gl-button
          size="small"
          category="primary"
          variant="confirm"
          icon="plus"
          :to="flowEditorRoute"
          data-testid="create-flow-button"
        >
          {{ s__('FlowEditor|Create flow') }}
        </gl-button>
      </div>
    </div>
  </div>
</template>
