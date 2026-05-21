<script>
import { defineComponent } from 'vue';
import { GlModal, GlSprintf } from '@gitlab/ui';
import { createAlert } from '~/alert';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { s__, sprintf } from '~/locale';
import orbitUpdateMutation from '../graphql/mutations/orbit_update.mutation.graphql';

export default defineComponent({
  name: 'TurnOnIndexingModal',
  compatConfig: { MODE: 3 },
  components: {
    GlModal,
    GlSprintf,
  },
  props: {
    group: {
      type: Object,
      required: false,
      default: null,
    },
    modalId: {
      type: String,
      required: false,
      default: 'orbit-turn-on-indexing-modal',
    },
  },
  emits: ['enabled', 'hidden'],
  data() {
    return {
      enabling: false,
      visible: false,
    };
  },
  computed: {
    title() {
      if (!this.group) return '';
      return sprintf(s__('Orbit|Turn on Orbit indexing for %{groupName}'), {
        groupName: this.group.name,
      });
    },
    primaryAction() {
      return {
        text: s__('Orbit|Turn on indexing'),
        attributes: { variant: 'confirm', loading: this.enabling },
      };
    },
    cancelAction() {
      return {
        text: s__('Orbit|Cancel'),
        attributes: { disabled: this.enabling },
      };
    },
  },
  watch: {
    group: {
      immediate: true,
      handler(newVal) {
        this.visible = Boolean(newVal);
      },
    },
  },
  methods: {
    onChange(value) {
      this.visible = value;
    },
    onHidden() {
      if (this.enabling) return;
      this.$emit('hidden');
    },
    async onPrimary() {
      if (!this.group || this.enabling) return;
      this.enabling = true;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: orbitUpdateMutation,
          variables: {
            input: { groupPath: this.group.fullPath, enabled: true },
          },
        });

        const result = data.orbitUpdate;
        if (result.errors.length) {
          throw new Error(result.errors.join(', '));
        }

        this.$emit('enabled', this.group);
        this.visible = false;
      } catch (error) {
        Sentry.captureException(error);
        createAlert({
          message: s__('Orbit|Failed to enable Orbit. Please try again.'),
        });
      } finally {
        this.enabling = false;
      }
    },
  },
});
</script>

<template>
  <gl-modal
    :visible="visible"
    :modal-id="modalId"
    :title="title"
    :action-primary="primaryAction"
    :action-cancel="cancelAction"
    data-testid="orbit-turn-on-indexing-modal"
    @change="onChange"
    @primary.prevent="onPrimary"
    @hidden="onHidden"
  >
    <p>
      {{
        s__(
          "Orbit|All content from this group, its subgroups, and projects will be added to Orbit. Existing access controls still apply — users who cannot access content in this group won't see it through Orbit.",
        )
      }}
    </p>
    <p>
      <gl-sprintf
        :message="
          s__(
            'Orbit|%{boldStart}The initial scan can take some time depending on the amount of content.%{boldEnd} After that, updated content is automatically re-indexed. You can turn off Orbit at any time.',
          )
        "
      >
        <template #bold="{ content }">
          <strong>{{ content }}</strong>
        </template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
