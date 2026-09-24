<script>
import { GlButton } from '@gitlab/ui';
import PdfViewer from '~/blob/pdf/pdf_viewer.vue';
import CePdfViewer from '~/repository/components/blob_viewers/pdf_viewer.vue';
import BlobMixin from './mixins/blob_mixin';

export default {
  components: {
    GlButton,
    PdfViewer,
  },
  extends: CePdfViewer,
  mixins: [BlobMixin],
};
</script>
<template>
  <div>
    <pdf-viewer v-if="!tooLargeToDisplay" :pdf="url" @pdflabload="handleOnLoad" />

    <div v-else class="gl-flex gl-flex-col gl-items-center gl-p-5">
      <p>{{ $options.i18n.tooLargeDescription }}</p>

      <gl-button
        v-if="canDownload"
        icon="download"
        category="secondary"
        variant="confirm"
        :href="url"
        download
        >{{ $options.i18n.tooLargeButtonText }}</gl-button
      >
    </div>
  </div>
</template>
