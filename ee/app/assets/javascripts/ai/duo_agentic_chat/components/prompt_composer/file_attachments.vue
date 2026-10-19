<script>
import { GlAlert } from '@gitlab/ui';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  ALLOWED_IMAGE_MIME_TYPES,
  buildAttachments,
  filesFromDataTransfer,
  isSupportedAttachmentType,
} from '../../utils/attachment_utils';
import AttachmentPreviews from './attachment_previews.vue';

const i18n = {
  CANNOT_QUEUE_ATTACHMENTS: s__(
    'DuoAgenticChat|Images cannot be queued. Send this message again once the current response finishes.',
  ),
};

/**
 * Every way a file can reach the composer -- the picker, a paste, a drop on the chat
 * panel -- and everything that follows from one: validation, the rejection notices and
 * the previews. The drop target itself is the panel's `<attachment-drop-zone>`, which
 * hands the files down to `addFiles`.
 *
 * The attachments themselves live on the composer's draft rather than here, so that
 * one object carries the whole prompt. This component reads them as a prop and asks
 * for changes, which keeps the draft the single source of truth for what will be sent.
 */
export default {
  name: 'FileAttachments',
  ACCEPTED_IMAGE_TYPES: ALLOWED_IMAGE_MIME_TYPES.join(','),
  components: {
    GlAlert,
    AttachmentPreviews,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    attachments: {
      type: Array,
      required: false,
      default: () => [],
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['add', 'remove'],
  data() {
    return {
      errors: [],
    };
  },
  computed: {
    isEnabled() {
      return Boolean(this.glFeatures?.dapWebChatFileAttachments);
    },
    // Rendering stays on `isEnabled` alone: a draft composed before the chat became
    // unavailable keeps its previews and notices, only new files are turned away.
    canAttach() {
      return this.isEnabled && !this.disabled;
    },
  },
  methods: {
    // The single gate for every entry point. Nothing reaches `buildAttachments`
    // without passing through here, so the flag and the limits cannot be bypassed
    // by one route while holding on another. Also called by the composer via $refs
    // for files dropped on the chat panel.
    async addFiles(files) {
      if (!this.canAttach || !files.length) return;

      const { attachments, errors } = await buildAttachments({
        files,
        existing: this.attachments,
      });

      // Deduplicated because the notices are keyed by their text: two files rejected for
      // the same reason under the same name (pasted images share a generated filename)
      // would otherwise collide as keys and dismiss together.
      this.errors = [...new Set(errors)];

      if (attachments.length) this.$emit('add', attachments);
    },
    // Called by the composer via $refs.
    // eslint-disable-next-line vue/no-unused-properties
    openFilePicker() {
      if (!this.canAttach) return;

      this.$refs.fileInput?.click();
    },
    // Called by the composer via $refs, once a send has cleared the draft.
    // eslint-disable-next-line vue/no-unused-properties
    clearErrors() {
      this.errors = [];
    },
    /**
     * The queue persists to sessionStorage, which cannot carry base64 image payloads.
     * Queueing the text alone would detach the images from the message they belong to,
     * so the composer holds the whole submission back and says why.
     *
     * Called by the composer via $refs.
     */
    // eslint-disable-next-line vue/no-unused-properties
    rejectQueueing() {
      this.errors = [i18n.CANNOT_QUEUE_ATTACHMENTS];
    },
    dismissError(error) {
      this.errors = this.errors.filter((current) => current !== error);
    },
    onRemove(id) {
      this.$emit('remove', id);
    },
    async onFileInputChange(event) {
      const input = event.target;

      await this.addFiles(Array.from(input.files || []));
      // Reset so re-picking the same file fires `change` again.
      input.value = '';
    },
    // Called by the composer via $refs.
    // eslint-disable-next-line vue/no-unused-properties
    onPaste(event) {
      if (!this.canAttach) return;

      const files = filesFromDataTransfer(event.clipboardData);

      // Claimed only when there is an image to take. Rich text can carry a file
      // alongside the text, and swallowing that paste would lose the text.
      if (!files.some(isSupportedAttachmentType)) return;

      event.preventDefault();
      this.addFiles(files);
    },
  },
  i18n,
};
</script>
<template>
  <div v-if="isEnabled" data-testid="file-attachments">
    <input
      ref="fileInput"
      type="file"
      multiple
      class="gl-sr-only"
      :accept="$options.ACCEPTED_IMAGE_TYPES"
      data-testid="attachment-file-input"
      @change="onFileInputChange"
    />
    <gl-alert
      v-for="error in errors"
      :key="error"
      variant="warning"
      class="gl-mb-3"
      data-testid="attachment-error"
      @dismiss="dismissError(error)"
    >
      {{ error }}
    </gl-alert>
    <attachment-previews :attachments="attachments" :disabled="disabled" @remove="onRemove" />
  </div>
</template>
