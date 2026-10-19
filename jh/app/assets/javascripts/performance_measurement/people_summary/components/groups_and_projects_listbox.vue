<script>
import { GlCollapsibleListbox } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/project_avatar.vue';
import getGroupsAndProjectsQuery from '../graphql/queries/get_groups_and_projects.query.graphql';

export default {
  components: {
    GlCollapsibleListbox,
    ProjectAvatar,
  },
  props: {
    placeholder: {
      type: String,
      required: false,
      default: '',
    },
    isValid: {
      type: Boolean,
      required: false,
      default: true,
    },
    value: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      groupsAndProjects: { groups: [], projects: [] },
      search: '',
    };
  },
  apollo: {
    groupsAndProjects: {
      query: getGroupsAndProjectsQuery,
      variables() {
        return {
          search: this.search,
        };
      },
      update(data) {
        return {
          groups: data?.groups?.nodes,
          projects: data?.projects?.nodes,
        };
      },
    },
  },
  computed: {
    listboxItems() {
      const { groups = [], projects = [] } = this.groupsAndProjects;
      return [
        {
          text: __('Groups'),
          options: groups.map(this.setValueToFullPath),
        },
        {
          text: __('Projects'),
          options: projects.map(this.setValueToFullPath),
        },
      ];
    },
    loading() {
      return this.$apollo.queries.groupsAndProjects.loading;
    },
    toggleText() {
      const { value } = this;
      if (!value?.length) {
        return this.placeholder;
      }

      const first = value[0];
      return value.length > 1
        ? sprintf(__('%{firstLabel} +%{labelCount} more'), {
            firstLabel: first,
            labelCount: value.length - 1,
          })
        : first;
    },
  },
  methods: {
    onSelect(path) {
      this.$emit('input', path);
    },
    onSearch(query) {
      this.search = query;
    },
    setValueToFullPath(item) {
      return { ...item, value: item.fullPath };
    },
  },
};
</script>
<template>
  <gl-collapsible-listbox
    :items="listboxItems"
    :value="value"
    :selected="value"
    :toggle-text="toggleText"
    multiple
    fluid-width
    block
    searchable
    is-check-centered
    :searching="loading"
    :toggle-class="{ '!gl-border-1 !gl-border-red-500': !isValid, '!gl-text-gray-500': !value }"
    @select="onSelect"
    @search="onSearch"
  >
    <template #list-item="{ item: { id, name, avatarUrl, fullPath } }">
      <div class="gl-inline-flex gl-items-center">
        <project-avatar
          :alt="name"
          :project-avatar-url="avatarUrl"
          :project-id="id"
          :project-name="name"
          class="gl-mr-3"
        />
        <span>{{ fullPath }}</span>
      </div>
    </template>
  </gl-collapsible-listbox>
</template>
