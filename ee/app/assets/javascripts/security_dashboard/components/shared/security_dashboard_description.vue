<script>
import { GlSprintf, GlLink, GlIcon } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  name: 'SecurityDashboardDescription',
  components: {
    GlSprintf,
    GlLink,
    GlIcon,
  },
  securityDashboardHelpLink: helpPagePath('user/application_security/security_dashboard/_index'),
};
</script>

<template>
  <div class="gl-w-full">
    <gl-sprintf
      :message="
        s__(
          'SecurityReports|Panels that categorize vulnerabilities as open include those with Needs triage or Confirmed status. Hover over the info icon (%{infoIcon}) to view more information about the data shown in each panel. To interact with a link in a chart popover, click to pin the popover first. To unstick it, click outside the popover. This dashboard might show higher vulnerability totals than the vulnerability report, which splits results across the Development, Operational, and Container registry tabs. %{learnMoreStart}Learn more%{learnMoreEnd}',
        )
      "
    >
      <template #learnMore="{ content }">
        <gl-link :href="$options.securityDashboardHelpLink" target="_blank">{{ content }}</gl-link>
      </template>
      <template #infoIcon>
        <gl-icon name="information-o" />
      </template>
    </gl-sprintf>
  </div>
</template>
