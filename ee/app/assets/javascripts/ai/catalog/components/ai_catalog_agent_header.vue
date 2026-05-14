<script>
import PageHeading from '~/vue_shared/components/page_heading.vue';

export default {
  name: 'DetailPageHeader',
  components: {
    PageHeading,
  },
  props: {
    heading: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <page-heading>
    <template #heading>
      {{ heading }}
    </template>
    <template #description>
      {{ description }}
    </template>
  </page-heading>
</template>
