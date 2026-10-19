<script>
import { defineComponent } from 'vue';
import { GlAccordion, GlAccordionItem, GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { JSON_QUERY_EXAMPLES, JSON_QUERY_REFERENCE_URL } from './constants';

export default defineComponent({
  name: 'QueryJsonExamples',
  compatConfig: { MODE: 3 },
  components: { ClipboardButton, GlAccordion, GlAccordionItem, GlAlert, GlLink, GlSprintf },
  jsonQueryExamples: JSON_QUERY_EXAMPLES.map(({ title, query }) => ({
    title,
    code: JSON.stringify(query, null, 2),
  })),
  jsonQueryReferenceUrl: JSON_QUERY_REFERENCE_URL,
});
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-4 gl-pt-3">
    <gl-alert variant="warning" :dismissible="false">
      {{ s__('Orbit|The JSON query format is going away. GQL replaces it soon.') }}
    </gl-alert>
    <p class="gl-mb-0 gl-text-sm gl-text-subtle">
      <gl-sprintf
        :message="
          s__(
            'Orbit|Copy an example and change the entities and filters. Use the Schema tab for names. %{linkStart}Full JSON query reference%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="$options.jsonQueryReferenceUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
    <gl-accordion :header-level="3" auto-collapse>
      <gl-accordion-item
        v-for="(example, index) in $options.jsonQueryExamples"
        :key="example.title"
        :title="example.title"
        :visible="index === 0"
      >
        <div class="gl-relative" data-testid="json-query-example">
          <pre class="gl-mb-0 gl-rounded-base gl-bg-strong gl-px-3 gl-py-2 gl-text-sm">{{
            example.code
          }}</pre>
          <clipboard-button
            :text="example.code"
            :title="s__('Orbit|Copy example')"
            category="tertiary"
            size="small"
            class="gl-absolute gl-right-2 gl-top-2"
          />
        </div>
      </gl-accordion-item>
    </gl-accordion>
  </div>
</template>
