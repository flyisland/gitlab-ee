<script>
export default {
  name: 'ActionTableCell',
  props: {
    text: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <span>{{ text }}</span>
</template>
