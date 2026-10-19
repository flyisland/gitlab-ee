<script>
import { defineComponent } from 'vue';
import { GlAlert, GlLink, GlSprintf, GlToggle } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { SETTING_AUTO_INDEX, SETTING_DUO_DEFAULT } from './constants';

export default defineComponent({
  name: 'AdminInstanceSettings',
  compatConfig: { MODE: 3 },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    GlToggle,
  },
  props: {
    autoIndexEnabled: {
      type: Boolean,
      required: true,
    },
    duoDefaultEnabled: {
      type: Boolean,
      required: true,
    },
    savingSetting: {
      type: String,
      required: false,
      default: null,
    },
    saveError: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['change', 'dismiss-error'],
  computed: {
    isSaving() {
      return this.savingSetting !== null;
    },
  },
  methods: {
    emitChange(setting, value) {
      this.$emit('change', { setting, value });
    },
  },
  orbitHelpPath: helpPagePath('integration/orbit.md'),
  SETTING_AUTO_INDEX,
  SETTING_DUO_DEFAULT,
});
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-4">
    <gl-alert
      v-if="saveError"
      variant="danger"
      :title="s__('Orbit|Could not save the setting')"
      data-testid="orbit-settings-error"
      @dismiss="$emit('dismiss-error')"
    >
      {{ saveError }}
    </gl-alert>
    <section
      class="gl-border gl-rounded-lg gl-border-section gl-bg-section"
      :aria-label="s__('Orbit|Orbit settings')"
      data-testid="orbit-instance-settings"
    >
      <div class="gl-flex gl-items-start gl-gap-5 gl-p-5">
        <div class="gl-flex-1">
          <p class="gl-mb-1 gl-font-bold">
            {{ s__('Orbit|Turn on Orbit for all top-level groups automatically') }}
          </p>
          <p class="gl-mb-0 gl-text-subtle">
            <gl-sprintf
              :message="
                s__(
                  'Orbit|New and existing top-level groups are indexed, except excluded groups. %{linkStart}Learn more%{linkEnd}.',
                )
              "
            >
              <template #link="{ content }">
                <gl-link :href="$options.orbitHelpPath" target="_blank">{{ content }}</gl-link>
              </template>
            </gl-sprintf>
          </p>
        </div>
        <gl-toggle
          :value="autoIndexEnabled"
          :is-loading="savingSetting === $options.SETTING_AUTO_INDEX"
          :disabled="isSaving"
          :label="s__('Orbit|Turn on Orbit for all top-level groups automatically')"
          label-position="hidden"
          data-testid="auto-index-toggle"
          @change="emitChange($options.SETTING_AUTO_INDEX, $event)"
        />
      </div>
      <div class="gl-border-t gl-flex gl-items-start gl-gap-5 gl-border-t-section gl-p-5">
        <div class="gl-flex-1">
          <p class="gl-mb-1 gl-font-bold">
            {{ s__('Orbit|Turn on Orbit in GitLab Duo') }}
          </p>
          <p class="gl-mb-0 gl-text-subtle">
            {{
              s__(
                'Orbit|GitLab Duo Chat and agents can use Orbit data for groups that have Orbit on. This setting turns Orbit in GitLab Duo on or off for all users. It has no effect when GitLab Duo is off.',
              )
            }}
          </p>
        </div>
        <gl-toggle
          :value="duoDefaultEnabled"
          :is-loading="savingSetting === $options.SETTING_DUO_DEFAULT"
          :disabled="isSaving"
          :label="s__('Orbit|Turn on Orbit in GitLab Duo')"
          label-position="hidden"
          data-testid="duo-default-toggle"
          @change="emitChange($options.SETTING_DUO_DEFAULT, $event)"
        />
      </div>
    </section>
  </div>
</template>
