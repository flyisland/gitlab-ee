<script>
import { GlBadge, GlButton, GlIcon, GlLink } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  name: 'GitLabIntelligenceBanner',
  components: {
    GlBadge,
    GlButton,
    GlIcon,
    GlLink,
  },
  props: {
    exploreDashboardsPath: {
      type: String,
      required: true,
    },
  },
  // TODO: repoint once the Explore docs land, tracked in
  // https://gitlab.com/gitlab-org/gitlab/-/work_items/589513
  helpPageUrl: helpPagePath('user/analytics/analytics_dashboards'),
};
</script>

<template>
  <!-- brand-charcoal and neutral-0 are constant tokens, so the card stays dark in both color modes -->
  <section
    class="gradient-hero gl-rounded-lg gl-border-1 gl-border-solid gl-border-alpha-light-24 gl-bg-brand-charcoal gl-px-7 gl-py-9 gl-text-center gl-@container"
    data-testid="gitlab-intelligence-banner"
  >
    <div class="gl-mb-4 gl-flex gl-items-center gl-justify-center gl-gap-3">
      <gl-icon name="tanuki-ai" :size="32" class="gl-text-neutral-0" />
      <span class="gl-text-sm gl-font-bold gl-text-neutral-0">
        {{ s__('Analytics|Introducing GitLab Intelligence') }}
      </span>
      <gl-badge variant="info">{{ __('New') }}</gl-badge>
    </div>

    <h2 class="gl-mb-3 gl-mt-0 gl-text-800 gl-font-bold gl-text-neutral-0">
      {{ s__('Analytics|See everything. Ask anything.') }}
    </h2>
    <p class="gl-mx-auto gl-mb-0 gl-max-w-62 gl-text-lg gl-text-neutral-100">
      {{
        s__(
          'Analytics|See activity across your entire organization in one place, and ask GitLab Duo to explain what the numbers mean — without building a dashboard first.',
        )
      }}
    </p>

    <div class="gl-mt-5 gl-flex gl-flex-wrap gl-items-center gl-justify-center gl-gap-5">
      <gl-button variant="confirm" class="gradient-hero-cta" :href="exploreDashboardsPath">
        {{ s__('Analytics|Open GitLab Intelligence') }}
      </gl-button>
      <gl-link
        variant="unstyled"
        :href="$options.helpPageUrl"
        class="gl-text-neutral-0 gl-underline focus-visible:gl-focus"
      >
        {{ s__('Analytics|Learn more') }}
      </gl-link>
    </div>

    <ul
      class="gl-mb-0 gl-mt-7 gl-grid gl-list-none gl-grid-cols-1 gl-gap-6 gl-border-0 gl-border-t-1 gl-border-solid gl-border-alpha-light-24 gl-p-0 gl-pt-6 gl-text-left @md:gl-grid-cols-3"
    >
      <li>
        <gl-icon name="organization" class="gl-mb-3 gl-text-neutral-100" />
        <h3 class="gl-m-0 gl-mb-1 gl-text-base gl-font-bold gl-text-neutral-0">
          {{ s__('Analytics|Organization-wide view') }}
        </h3>
        <p class="gl-m-0 gl-text-sm gl-text-neutral-100">
          {{
            s__(
              'Analytics|Activity across every group and project in one place, instead of one dashboard per scope.',
            )
          }}
        </p>
      </li>
      <li>
        <gl-icon name="tanuki-ai" class="gl-mb-3 gl-text-neutral-100" />
        <h3 class="gl-m-0 gl-mb-1 gl-text-base gl-font-bold gl-text-neutral-0">
          {{ s__('Analytics|Insights with GitLab Duo') }}
        </h3>
        <p class="gl-m-0 gl-text-sm gl-text-neutral-100">
          {{
            s__(
              'Analytics|Ask what a trend means and get an answer grounded in the data on the page.',
            )
          }}
        </p>
      </li>
      <li>
        <gl-icon name="dashboard" class="gl-mb-3 gl-text-neutral-100" />
        <h3 class="gl-m-0 gl-mb-1 gl-text-base gl-font-bold gl-text-neutral-0">
          {{ s__('Analytics|Build your own dashboards') }}
        </h3>
        <p class="gl-m-0 gl-text-sm gl-text-neutral-100">
          {{
            s__(
              'Analytics|Start from a template or compose panels yourself, and share them with your teams.',
            )
          }}
        </p>
      </li>
    </ul>
  </section>
</template>
