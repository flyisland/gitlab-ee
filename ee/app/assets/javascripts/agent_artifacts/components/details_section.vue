<script>
import { s__ } from '~/locale';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import CollapsibleText from './collapsible_text.vue';

const LARGE_TEXT_KEYS = {
  goal: s__('AgentArtifacts|Goal'),
  prompt_content: s__('AgentArtifacts|Prompt content'),
  response_content: s__('AgentArtifacts|Response content'),
  tool_args: s__('AgentArtifacts|Tool arguments'),
  content: s__('AgentArtifacts|Content'),
  error_message: s__('AgentArtifacts|Error message'),
  previous_error: s__('AgentArtifacts|Previous error'),
};

const humanize = (key) =>
  key
    .replace(/_/g, ' ')
    .replace(/^\w/, (char) => char.toUpperCase())
    .trim();

const formatValue = (value) =>
  value !== null && typeof value === 'object' ? JSON.stringify(value) : String(value);

export default {
  name: 'DetailsSection',
  components: {
    CrudComponent,
    CollapsibleText,
  },
  props: {
    details: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    fields() {
      return Object.entries(this.details)
        .filter(
          ([key, value]) => !(key in LARGE_TEXT_KEYS) && value !== null && value !== undefined,
        )
        .map(([key, value]) => ({
          key,
          label: humanize(key),
          value: formatValue(value),
        }));
    },
    leftColumn() {
      return this.fields.slice(0, Math.ceil(this.fields.length / 2));
    },
    rightColumn() {
      return this.fields.slice(Math.ceil(this.fields.length / 2));
    },
    columns() {
      return [this.leftColumn, this.rightColumn];
    },
    blocks() {
      return Object.entries(LARGE_TEXT_KEYS)
        .filter(([key]) => Boolean(this.details[key]))
        .map(([key, label]) => ({ key, label, value: formatValue(this.details[key]) }));
    },
    isEmpty() {
      return this.fields.length === 0 && this.blocks.length === 0;
    },
  },
  i18n: {
    title: s__('AgentArtifacts|Details'),
    empty: s__('AgentArtifacts|No details available for this event.'),
  },
};
</script>

<template>
  <crud-component :title="$options.i18n.title" is-collapsible>
    <div v-if="isEmpty" class="gl-text-subtle" data-testid="details-empty">
      {{ $options.i18n.empty }}
    </div>
    <template v-else>
      <div
        v-if="fields.length"
        class="gl-flex gl-flex-col @sm/panel:gl-flex-row @sm/panel:gl-gap-x-7"
      >
        <ul
          v-for="(column, index) in columns"
          :key="index"
          class="gl-m-0 gl-list-disc gl-pl-5 @sm/panel:gl-w-1/2"
        >
          <li
            v-for="field in column"
            :key="field.key"
            :data-testid="`details-field-${field.key}`"
            class="gl-break-words gl-py-1"
          >
            <span class="gl-font-bold">{{ field.label }}</span>
            - <span>{{ field.value }}</span>
          </li>
        </ul>
      </div>

      <div
        v-for="block in blocks"
        :key="block.key"
        class="gl-pt-5"
        :data-testid="`details-block-${block.key}`"
      >
        <span class="gl-mb-2 gl-block gl-font-bold">{{ block.label }}</span>
        <collapsible-text :text="block.value" />
      </div>
    </template>
  </crud-component>
</template>
