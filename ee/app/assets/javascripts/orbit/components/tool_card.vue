<script>
import { GlIcon, GlButton } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { TOON_BLOCK_PATTERN } from '../constants';

export default {
  name: 'ToolCard',
  compatConfig: { MODE: 3 },
  components: {
    GlIcon,
    GlButton,
    ClipboardButton,
  },
  props: {
    tool: {
      type: Object,
      required: true,
    },
    samplePrompt: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      expanded: false,
    };
  },
  computed: {
    summary() {
      const description = this.tool.description || '';
      return description.replace(TOON_BLOCK_PATTERN, '').trim();
    },
    schema() {
      const description = this.tool.description || '';
      const match = description.match(TOON_BLOCK_PATTERN);
      return match ? match[1].trim() : '';
    },
  },
  methods: {
    toggleExpand() {
      this.expanded = !this.expanded;
    },
  },
};
</script>

<template>
  <div
    class="gl-flex-1 gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-subtle"
  >
    <div class="gl-flex gl-items-center gl-gap-2 gl-bg-strong gl-px-4 gl-py-3">
      <code class="gl-font-bold">{{ tool.name }}</code>
      <clipboard-button
        :text="tool.name"
        :title="s__('Orbit|Copy tool name')"
        size="small"
        category="tertiary"
        css-class="gl-text-subtle"
      />
    </div>
    <div class="gl-p-4">
      <p class="gl-font-sm gl-mb-2 gl-whitespace-pre-line">{{ summary }}</p>
      <pre
        v-if="expanded && schema"
        class="gl-font-sm gl-mb-2 gl-overflow-x-auto gl-whitespace-pre-wrap gl-rounded-lg gl-bg-strong gl-p-3 gl-font-monospace"
        >{{ schema }}</pre
      >
      <gl-button
        v-if="schema"
        variant="link"
        size="small"
        data-testid="toggle-tool-schema"
        class="gl-mb-3"
        @click="toggleExpand"
      >
        {{ expanded ? s__('Orbit|Show less') : s__('Orbit|Show more') }}
      </gl-button>
      <div v-if="samplePrompt">
        <p class="gl-font-sm gl-mb-2 gl-font-bold">{{ s__('Orbit|Sample prompt') }}</p>
        <div class="gl-flex gl-items-start gl-gap-2 gl-text-subtle">
          <gl-icon name="comment" :size="14" class="gl-mt-1 gl-flex-shrink-0" />
          <span class="gl-font-sm gl-italic">"{{ samplePrompt }}"</span>
        </div>
      </div>
    </div>
  </div>
</template>
