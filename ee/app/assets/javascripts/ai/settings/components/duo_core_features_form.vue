<script>
import { GlFormCheckbox, GlFormGroup, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { DOCS_URL } from '~/constants';
import PromoPageLink from '~/vue_shared/components/promo_page_link/promo_page_link.vue';

export default {
  name: 'DuoCoreFeaturesForm',
  i18n: {
    sectionTitle: __('GitLab Duo Core'),
    subtitle: s__(
      'AiPowered|Allow users without a GitLab Duo Pro or Enterprise seat to access GitLab Duo Agent Platform features. %{linkStart}Which features are included%{linkEnd}?',
    ),
    checkboxLabel: s__('AiPowered|Turn on GitLab Duo Agent Platform access'),
    checkboxHelpTextSaaS: s__(
      'AiPowered|This setting applies to the top-level group. By turning on these features, you accept the %{termsLinkStart}GitLab Duo AI Terms%{termsLinkEnd} unless your organization has a separate agreement with GitLab that governs AI usage. %{prerequisitesLinkStart}What are the prerequisites for the GitLab Duo Agent Platform%{prerequisitesLinkEnd}?',
    ),
    checkboxHelpTextSelfManaged: s__(
      'AiPowered|This setting applies to the entire instance. By turning on these features, you accept the %{termsLinkStart}GitLab Duo AI Terms%{termsLinkEnd} unless your organization has a separate agreement with GitLab that governs AI usage. %{prerequisitesLinkStart}What are the prerequisites for the GitLab Duo Agent Platform%{prerequisitesLinkEnd}?',
    ),
  },
  components: {
    GlFormCheckbox,
    GlFormGroup,
    GlLink,
    GlSprintf,
    PromoPageLink,
  },
  directives: {
    tooltip: GlTooltipDirective,
  },
  inject: ['isSaaS'],
  props: {
    disabledCheckbox: {
      type: Boolean,
      required: true,
    },
    duoCoreFeaturesEnabled: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      duoCoreEnabled: this.duoCoreFeaturesEnabled,
    };
  },
  computed: {
    description() {
      return this.isSaaS
        ? this.$options.i18n.checkboxHelpTextSaaS
        : this.$options.i18n.checkboxHelpTextSelfManaged;
    },
  },
  methods: {
    checkboxChanged() {
      this.$emit('change', this.duoCoreEnabled);
    },
  },
  termsPath: `/handbook/legal/ai-functionality-terms/`,
  duoCoreFeaturesPath: `${DOCS_URL}/user/gitlab_duo/feature_summary/`,
  duoCorePrerequisitesPath: `${DOCS_URL}/user/duo_agent_platform/#prerequisites`,
};
</script>
<template>
  <div>
    <gl-form-group :label="$options.i18n.sectionTitle" class="gl-my-4">
      <template #label-description>
        <gl-sprintf :message="$options.i18n.subtitle">
          <template #link="{ content }">
            <gl-link :href="$options.duoCoreFeaturesPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </template>
      <gl-form-checkbox
        v-model="duoCoreEnabled"
        data-testid="use-duo-core-features-checkbox"
        :disabled="disabledCheckbox"
        @change="checkboxChanged"
      >
        <span
          id="duo-core-checkbox-label"
          v-tooltip="
            disabledCheckbox
              ? s__('AiPowered|This setting only applies when GitLab Duo is available.')
              : ''
          "
          >{{ $options.i18n.checkboxLabel }}</span
        >
        <template #help>
          <gl-sprintf :message="description">
            <template #br>
              <br />
            </template>
            <template #termsLink="{ content }">
              <promo-page-link :path="$options.termsPath" target="_blank">{{
                content
              }}</promo-page-link>
            </template>
            <template #prerequisitesLink="{ content }">
              <gl-link :href="$options.duoCorePrerequisitesPath" target="_blank">{{
                content
              }}</gl-link>
            </template>
          </gl-sprintf>
        </template>
      </gl-form-checkbox>
    </gl-form-group>
  </div>
</template>
