<script>
import { GlSprintf, GlLink } from '@gitlab/ui';
import CeLfsViewer from '~/repository/components/blob_viewers/lfs_viewer.vue';
import BlobMixin from './mixins/blob_mixin';

export default {
  components: {
    GlSprintf,
    GlLink,
  },
  extends: CeLfsViewer,
  mixins: [BlobMixin],
};
</script>
<template>
  <div class="gl-bg-gray-50 gl-py-13 gl-text-center" data-type="lfs">
    <gl-sprintf v-if="canDownload" :message="$options.i18n.lfsText">
      <template #link="{ content }">
        <gl-link :href="filePath" :download="fileName" target="_blank">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div v-else>
      {{ __('No preview for this file type') }}
    </div>
  </div>
</template>
