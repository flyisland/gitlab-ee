<script>
import { GlButton, GlCollapse } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'CollapsibleText',
  components: {
    GlButton,
    GlCollapse,
  },
  props: {
    text: {
      type: String,
      required: false,
      default: '',
    },
    threshold: {
      type: Number,
      required: false,
      default: 500,
    },
  },
  data() {
    return {
      visible: false,
    };
  },
  computed: {
    isLong() {
      return this.text.length > this.threshold;
    },
    preview() {
      return this.text.slice(0, this.threshold);
    },
    toggleLabel() {
      return this.visible ? this.$options.i18n.showLess : this.$options.i18n.showMore;
    },
  },
  methods: {
    toggle() {
      this.visible = !this.visible;
    },
  },
  i18n: {
    showMore: s__('AgentArtifacts|Show more'),
    showLess: s__('AgentArtifacts|Show less'),
  },
};
</script>

<template>
  <div>
    <span v-if="!isLong" class="gl-whitespace-pre-wrap gl-break-words">{{ text }}</span>
    <template v-else>
      <span
        v-if="!visible"
        class="gl-whitespace-pre-wrap gl-break-words"
        data-testid="collapsible-text-preview"
        >{{ preview }}</span
      >
      <gl-collapse :visible="visible">
        <span class="gl-whitespace-pre-wrap gl-break-words" data-testid="collapsible-text-full">{{
          text
        }}</span>
      </gl-collapse>
      <gl-button
        category="tertiary"
        size="small"
        data-testid="collapsible-text-toggle"
        @click="toggle"
      >
        {{ toggleLabel }}
      </gl-button>
    </template>
  </div>
</template>
