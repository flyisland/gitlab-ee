<script>
import { s__ } from '~/locale';

export default {
  name: 'AiOverviewApp',
  i18n: {
    heading: s__('AiOverview|AI Overview'),
  },
};
</script>

<template>
  <div class="ai-overview-body gl-py-5">
    <h2 class="gl-sr-only">{{ $options.i18n.heading }}</h2>
  </div>
</template>
