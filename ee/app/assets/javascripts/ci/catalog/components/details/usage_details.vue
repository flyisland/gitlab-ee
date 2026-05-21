<script>
import { GlTable, GlLink, GlIcon, GlTruncateText, GlKeysetPagination } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'UsageDetails',
  components: {
    GlTable,
    GlIcon,
    GlLink,
    GlTruncateText,
    GlKeysetPagination,
  },
  props: {
    componentUsages: {
      type: Array,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: true,
    },
  },
  emits: ['next-page', 'prev-page'],
  computed: {
    items() {
      return this.componentUsages.map((item) => {
        const sortedComponents = this.sortComponents(item.componentsUsed);
        const oldestComponent = sortedComponents[0];
        return {
          project: item.project,
          oldestComponent,
          isOutdatedVersion: oldestComponent.outdated,
          componentsUsedString: this.formatComponentsList(sortedComponents),
        };
      });
    },
  },
  methods: {
    sortComponents(components) {
      return [...components].sort((a, b) => {
        return a.version.name.localeCompare(b.version.name, undefined, { numeric: true });
      });
    },
    formatComponentsList(sortedComponents) {
      return sortedComponents
        .map((item) => {
          return `${item.component.name} (${item.version.name})`;
        })
        .join(', ');
    },
  },
  tableFields: [
    {
      key: 'project',
      label: s__('CiCatalog|Project path'),
      thClass: '@lg/panel:gl-w-3/10',
    },
    {
      key: 'status',
      label: s__('CiCatalog|Status'),
      thClass: '@lg/panel:gl-w-1/5',
    },
    {
      key: 'componentsUsed',
      label: s__('CiCatalog|Components used'),
      thClass: 'gl-text-right',
      tdClass: 'gl-text-right',
    },
  ],
  toggleButtonProps: { class: '!gl-text-sm' },
};
</script>
<template>
  <div>
    <h2 class="gl-mt-5 gl-text-size-h2">{{ s__('CiCatalog|Usage statistics') }}</h2>
    <p class="gl-mb-5 gl-text-secondary">
      {{
        s__(
          'CiCatalog|The list of projects that included a component from this project in a pipeline in the last 30 days. Only displays projects you have permission to view.',
        )
      }}
    </p>

    <gl-table :items="items" :fields="$options.tableFields" stacked="sm" fixed>
      <template #head(componentsUsed)>
        <span class="gl-ml-auto">{{ s__('CiCatalog|Components used') }}</span>
      </template>
      <template #cell(project)="{ item: { project } }">
        <gl-link v-if="project" :href="project.webPath" class="gl-font-bold">{{
          project.nameWithNamespace
        }}</gl-link>
        <span v-else class="gl-text-subtle">{{ s__('CiCatalog|Private project') }}</span>
      </template>
      <template #cell(status)="{ item }">
        <span v-if="item.isOutdatedVersion" class="gl-text-sm"
          ><gl-icon name="warning" class="gl-text-warning" />
          {{ s__('CiCatalog|Outdated') }} &middot; {{ item.oldestComponent.version.name }}</span
        ><span v-else class="gl-text-sm"
          ><gl-icon name="status_success" class="gl-text-success" />
          {{ s__('CiCatalog|Up to date') }} &middot; {{ item.oldestComponent.version.name }}</span
        >
      </template>
      <template #cell(componentsUsed)="{ item }">
        <div class="gl-flex gl-flex-col gl-items-end gl-gap-2">
          <gl-truncate-text
            class="gl-text-sm"
            :show-more-text="s__('CiCatalog|See more')"
            :show-less-text="s__('CiCatalog|See less')"
            :toggle-button-props="$options.toggleButtonProps"
            :lines="2"
            :mobile-lines="4"
          >
            {{ item.componentsUsedString }}
          </gl-truncate-text>
        </div>
      </template>
    </gl-table>
    <div class="gl-mt-5 gl-flex gl-justify-center">
      <gl-keyset-pagination
        v-bind="pageInfo"
        :prev-text="__('Previous')"
        :next-text="__('Next')"
        @prev="$emit('prev-page')"
        @next="$emit('next-page')"
      />
    </div>
  </div>
</template>
