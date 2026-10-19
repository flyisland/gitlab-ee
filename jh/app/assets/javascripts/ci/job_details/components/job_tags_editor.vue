<script>
import { mapActions, mapState } from 'vuex';
import { GlAlert, GlButton, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';

export default {
  name: 'JobTagsEditor',
  components: { GlAlert, GlButton, GlForm, GlFormGroup, GlFormInput },
  data() {
    return {
      editing: false,
      tags: '',
      saving: false,
      error: '',
    };
  },
  computed: {
    ...mapState(['job', 'jobEndpoint']),
  },
  methods: {
    ...mapActions(['receiveJobSuccess']),
    editTags() {
      this.tags = (this.job.tags || [])
        .map((tag) => (tag.includes(',') ? `"${tag}"` : tag))
        .join(', ');
      this.error = '';
      this.editing = true;
    },
    async saveTags() {
      this.saving = true;
      this.error = '';

      try {
        const { data } = await axios.patch(this.job.update_tags_path, { tags: [this.tags] });
        this.receiveJobSuccess({ ...this.job, tags: data.tags });
        this.editing = false;
        await axios
          .get(this.jobEndpoint)
          .then(({ data: job }) => this.receiveJobSuccess(job))
          .catch(() =>
            createAlert({
              message: s__(
                'JH|Job|Tags were saved, but the job details could not be updated. Refresh the page to see the latest status.',
              ),
            }),
          );
      } catch (error) {
        this.error = error.response?.data?.message || s__('JH|Job|Failed to update job tags.');
      } finally {
        this.saving = false;
      }
    },
  },
};
</script>

<template>
  <div
    v-if="job.update_tags_path"
    class="gl-mb-4"
    :class="{ 'gl-border-t gl-border-subtle gl-pt-4': !job.tags?.length }"
  >
    <h2 v-if="!job.tags?.length" class="gl-mb-3 gl-mt-0 gl-text-md gl-font-bold">
      {{ __('Tags') }}
    </h2>
    <gl-button v-if="!editing" size="small" data-testid="edit-job-tags" @click="editTags">
      {{ s__('JH|Job|Edit tags') }}
    </gl-button>
    <gl-form v-else @submit.prevent="saveTags">
      <gl-alert v-if="error" class="gl-mb-3" variant="danger" :dismissible="false">
        {{ error }}
      </gl-alert>
      <gl-form-group
        :label="__('Tags')"
        label-for="job-tags-input"
        label-sr-only
        :description="s__('JH|Job|Separate tags with commas. Clear the field to remove all tags.')"
      >
        <gl-form-input id="job-tags-input" v-model="tags" :disabled="saving" />
      </gl-form-group>
      <gl-button type="submit" size="small" variant="confirm" :loading="saving">
        {{ s__('JH|Job|Save tags') }}
      </gl-button>
      <gl-button size="small" :disabled="saving" @click="editing = false">
        {{ __('Cancel') }}
      </gl-button>
    </gl-form>
  </div>
</template>
