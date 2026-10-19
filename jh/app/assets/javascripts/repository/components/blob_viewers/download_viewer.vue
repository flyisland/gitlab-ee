<script>
import { GlIcon, GlLink } from '@gitlab/ui';
import CeDownloadViewer from '~/repository/components/blob_viewers/download_viewer.vue';
import BlobMixin from './mixins/blob_mixin';

export default {
  components: {
    GlIcon,
    GlLink,
  },
  extends: CeDownloadViewer,
  mixins: [BlobMixin],
};
</script>

<template>
  <div class="gl-bg-gray-50 gl-py-13 gl-text-center">
    <gl-link
      v-if="canDownload"
      :href="filePath"
      rel="nofollow"
      :download="fileName"
      target="_blank"
    >
      <div>
        <gl-icon :size="16" name="download" class="gl-text-gray-900" />
      </div>
      <h4>{{ downloadText }}</h4>
    </gl-link>
    <div v-else>
      {{ __('No preview for this file type') }}
    </div>
  </div>
</template>
