<script>
import { GlFilteredSearch, GlFilteredSearchToken } from '@gitlab/ui';
import { s__ } from '~/locale';
import {
  OPERATORS_IS,
  FILTERED_SEARCH_TERM,
} from '~/vue_shared/components/filtered_search_bar/constants';
import { TOKEN_TYPE_ACTION, ACTION_TOKEN_OPTIONS } from '../../constants';

export default {
  name: 'AiToolRulesFilteredSearch',
  components: {
    GlFilteredSearch,
  },
  emits: ['filter'],
  data() {
    return {
      // Bound value array drives chip rendering and `unique` single-token behaviour.
      filterValue: [],
    };
  },
  methods: {
    onInput(value) {
      this.filterValue = value;
    },
    onSubmit(terms) {
      const searchTerms = [];
      let actionType = null;

      // With `terms-as-tokens`, free text arrives as FILTERED_SEARCH_TERM token
      // objects and the action filter as an action token; both are objects.
      terms.forEach((term) => {
        if (term.type === TOKEN_TYPE_ACTION) {
          actionType = term.value?.data ?? null;
        } else if (term.type === FILTERED_SEARCH_TERM && term.value?.data) {
          searchTerms.push(term.value.data);
        }
      });

      const search = searchTerms.join(' ').trim();

      this.$emit('filter', { search: search || null, actionType });
    },
    onClear() {
      // The clear button emits `clear` (not `submit`), so reset the filter here
      // or the table keeps showing results after the bar is emptied.
      this.filterValue = [];
      this.$emit('filter', { search: null, actionType: null });
    },
  },
  availableTokens: [
    {
      type: TOKEN_TYPE_ACTION,
      title: s__('AiGovernance|Action'),
      icon: 'comparison',
      token: GlFilteredSearchToken,
      operators: OPERATORS_IS,
      unique: true,
      options: ACTION_TOKEN_OPTIONS,
    },
  ],
  i18n: {
    placeholder: s__('AiGovernance|Search or filter tool rules...'),
  },
};
</script>

<template>
  <div data-testid="ai-tool-rules-filtered-search">
    <gl-filtered-search
      :value="filterValue"
      :placeholder="$options.i18n.placeholder"
      :available-tokens="$options.availableTokens"
      :clear-button-title="__('Clear')"
      :close-button-title="__('Close')"
      terms-as-tokens
      @input="onInput"
      @submit="onSubmit"
      @clear="onClear"
    />
  </div>
</template>
