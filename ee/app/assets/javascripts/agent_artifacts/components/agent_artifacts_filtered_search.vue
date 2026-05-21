<script>
import { GlFilteredSearch } from '@gitlab/ui';
import {
  OPERATORS_IS,
  OPERATORS_IS_NOT,
} from '~/vue_shared/components/filtered_search_bar/constants';
import { s__ } from '~/locale';
import DateToken from '~/vue_shared/components/filtered_search_bar/tokens/date_token.vue';
import AiItemToken from './tokens/ai_item_token.vue';
import ProjectToken from './tokens/project_token.vue';

export default {
  name: 'AgentArtifactsFilteredSearch',
  components: {
    GlFilteredSearch,
  },
  inject: {
    groupId: { default: null },
  },
  emits: ['filter'],
  data() {
    return {
      filterValue: [],
    };
  },
  computed: {
    tokens() {
      return [
        {
          type: 'name',
          icon: 'tanuki-ai',
          title: s__('AgentArtifacts|AI Item'),
          token: AiItemToken,
          unique: true,
          operators: OPERATORS_IS_NOT,
        },
        {
          type: 'startTimeAfter',
          icon: 'calendar',
          title: s__('AgentArtifacts|Created after'),
          token: DateToken,
          unique: true,
          operators: OPERATORS_IS,
        },
        {
          type: 'startTimeBefore',
          icon: 'calendar',
          title: s__('AgentArtifacts|Created before'),
          token: DateToken,
          unique: true,
          operators: OPERATORS_IS,
        },
        this.groupId && {
          type: 'projectPath',
          icon: 'project',
          title: s__('AgentArtifacts|Project'),
          token: ProjectToken,
          unique: true,
          operators: OPERATORS_IS_NOT,
        },
      ].filter(Boolean);
    },
  },
  methods: {
    handleSubmit() {
      const variables = {};
      const notFilters = {};

      this.filterValue.forEach((filter) => {
        if (!filter.value?.data) return;

        const { data, operator } = filter.value;
        const { type } = filter;

        if (operator === '=') {
          variables[type] = data;
        } else if (operator === '!=') {
          notFilters[type] = data;
        }
      });

      if (Object.keys(notFilters).length > 0) {
        variables.not = notFilters;
      }

      this.$emit('filter', variables);
    },
  },
};
</script>

<template>
  <gl-filtered-search
    v-model="filterValue"
    :placeholder="s__('AgentArtifacts|Filter agent artifacts')"
    :available-tokens="tokens"
    terms-as-tokens
    @submit="handleSubmit"
    @clear="$emit('filter', {})"
  />
</template>
