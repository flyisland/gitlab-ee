<script>
import { GlAlert } from '@gitlab/ui';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import OnboardingAction from './components/onboarding_action.vue';

export default {
  name: 'ImproveCiOnboardingPage',
  components: {
    GlAlert,
    OnboardingAction,
    PageHeading,
  },
  i18n: {
    headingTitle: s__('DuoAgentsPlatform|Improve your CI setup'),
    headingDescription: s__(
      'DuoAgentsPlatform|Analyze your .gitlab-ci.yml and get actionable improvement suggestions in a new draft merge request.',
    ),
    noGitlabCiYmlAlert: s__(
      'DuoAgentsPlatform|No .gitlab-ci.yml found on the default branch. Add a CI configuration file to use this feature.',
    ),
    improveCiButton: s__('DuoAgentsPlatform|Improve CI setup'),
    fallbackErrorMessage: s__(
      'DuoAgentsPlatform|Something went wrong while starting the CI improvement workflow.',
    ),
  },
  data() {
    return {
      hasGitlabCiYml: Boolean(window.gon?.has_gitlab_ci_yml),
    };
  },
};
</script>
<template>
  <div>
    <page-heading>
      <template #heading>
        {{ $options.i18n.headingTitle }}
      </template>
      <template #description>
        {{ $options.i18n.headingDescription }}
      </template>
    </page-heading>

    <onboarding-action
      gon-path-key="improve_ci_path"
      :fallback-error-message="$options.i18n.fallbackErrorMessage"
      :button-label="$options.i18n.improveCiButton"
      :action-disabled="!hasGitlabCiYml"
      data-testid="improve-ci-action"
    >
      <template #prerequisite-alerts>
        <gl-alert
          v-if="!hasGitlabCiYml"
          variant="warning"
          :dismissible="false"
          data-testid="no-gitlab-ci-yml-alert"
        >
          {{ $options.i18n.noGitlabCiYmlAlert }}
        </gl-alert>
      </template>
    </onboarding-action>
  </div>
</template>
