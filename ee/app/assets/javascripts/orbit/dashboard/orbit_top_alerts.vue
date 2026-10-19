<script>
import { defineComponent } from 'vue';
import { GlAlert } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { isIndexing } from 'ee/orbit/utils/orbit_group_state';

export default defineComponent({
  name: 'OrbitTopAlerts',
  compatConfig: { MODE: 3 },
  components: { GlAlert },
  inject: ['defaultGroupMissing', 'preferencesPath'],
  props: {
    enabledGroups: {
      type: Array,
      required: true,
    },
    hasEndedTrial: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    indexingGroups() {
      return this.enabledGroups.filter(isIndexing);
    },
    hasIndexingGroups() {
      return this.indexingGroups.length > 0;
    },
    hasAlerts() {
      return this.hasEndedTrial || this.defaultGroupMissing || this.hasIndexingGroups;
    },
    indexingTitle() {
      if (this.enabledGroups.length === 1) {
        return sprintf(s__('Orbit|Indexing %{name}'), { name: this.indexingGroups[0].name });
      }

      return sprintf(s__('Orbit|Indexing %{indexing} of %{total} groups'), {
        indexing: this.indexingGroups.length,
        total: this.enabledGroups.length,
      });
    },
  },
});
</script>

<template>
  <div v-if="hasAlerts" class="gl-mb-5 gl-flex gl-flex-col gl-gap-4">
    <gl-alert
      v-if="hasEndedTrial"
      variant="warning"
      :title="s__('Orbit|One or more Orbit trials have ended')"
      :dismissible="false"
      data-testid="orbit-trial-ended-alert"
    >
      {{
        s__(
          'Orbit|Queries are paused for groups whose trial ended. Talk to your GitLab seller to keep using Orbit.',
        )
      }}
    </gl-alert>

    <gl-alert
      v-if="defaultGroupMissing"
      variant="warning"
      :title="s__('Orbit|Default group is not selected')"
      :dismissible="false"
      :primary-button-text="s__('Orbit|Go to preferences')"
      :primary-button-link="preferencesPath"
      data-testid="orbit-no-default-alert"
    >
      {{
        s__(
          'Orbit|You belong to multiple groups eligible for Orbit billing. Until you select one in your preferences, Orbit queries fail, but indexing continues.',
        )
      }}
    </gl-alert>

    <gl-alert
      v-if="hasIndexingGroups"
      variant="info"
      :title="indexingTitle"
      :dismissible="false"
      data-testid="orbit-indexing-alert"
    >
      {{
        s__(
          'Orbit|You can use Orbit when indexing is done, which may take several minutes to hours. You can leave this page and check back later.',
        )
      }}
    </gl-alert>
  </div>
</template>
