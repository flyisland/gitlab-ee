<script>
import { GlBadge, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'EnvironmentCard',
  components: {
    GlBadge,
    GlIcon,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
  },
  // TODO:  Remove the mocks
  mockCard: {
    apps: s__('ContinuousDeployment|5 apps'),
    release: 'v2.4.1',
    lastDeploy: s__('ContinuousDeployment|10m ago'),
    deployedBy: '@abc.com',
    region: 'eu-west-1',
    version: 'v1.28.4',
    clusterAgent: 'gitlab-agent-prod-eu',
  },
};
</script>

<template>
  <div
    class="gl-rounded-lg gl-border-1 gl-border-solid gl-border-subtle gl-p-4"
    data-testid="environment-card"
  >
    <div class="gl-flex gl-items-center gl-gap-3">
      <span class="gl-h-3 gl-w-3 gl-shrink-0 gl-rounded-full gl-bg-green-500"></span>
      <h2 class="gl-m-0 gl-truncate gl-text-base">{{ name }}</h2>
      <gl-badge class="gl-ml-auto" variant="success">
        {{ s__('ContinuousDeployment|Healthy') }}
      </gl-badge>
    </div>

    <div class="gl-mt-3 gl-flex gl-items-center gl-justify-between gl-text-subtle">
      <span class="gl-flex gl-items-center gl-gap-2">
        <gl-icon name="kubernetes" />
        {{ __('Kubernetes') }}
      </span>
      <span class="gl-flex gl-items-center gl-gap-2">
        <gl-icon name="applications" />
        {{ $options.mockCard.apps }}
      </span>
    </div>

    <div
      class="gl-mt-4 gl-flex gl-gap-6 gl-border-t-1 gl-border-t-subtle gl-pt-4 gl-border-t-solid"
    >
      <div>
        <div class="gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-subtle">
          {{ s__('ContinuousDeployment|Release') }}
        </div>
        <div class="gl-mt-1 gl-font-monospace gl-text-sm">{{ $options.mockCard.release }}</div>
      </div>
      <div>
        <div class="gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-subtle">
          {{ s__('ContinuousDeployment|Last deploy') }}
        </div>
        <div class="gl-mt-1 gl-font-monospace gl-text-sm">
          {{ $options.mockCard.lastDeploy }}
        </div>
      </div>
      <div class="gl-min-w-0">
        <div class="gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-subtle">
          {{ s__('ContinuousDeployment|By') }}
        </div>
        <div class="gl-mt-1 gl-truncate gl-font-monospace gl-text-sm">
          {{ $options.mockCard.deployedBy }}
        </div>
      </div>
    </div>

    <div
      class="gl-mt-4 gl-flex gl-flex-col gl-gap-3 gl-border-t-1 gl-border-t-subtle gl-pt-4 gl-text-sm gl-border-t-solid"
    >
      <div class="gl-flex gl-items-center gl-justify-between">
        <span class="gl-text-subtle">{{ s__('ContinuousDeployment|Region') }}</span>
        <span class="gl-font-monospace">{{ $options.mockCard.region }}</span>
      </div>
      <div class="gl-flex gl-items-center gl-justify-between">
        <span class="gl-text-subtle">{{ s__('ContinuousDeployment|Version') }}</span>
        <span class="gl-font-monospace">{{ $options.mockCard.version }}</span>
      </div>
      <div class="gl-flex gl-items-center gl-justify-between">
        <span class="gl-text-subtle">{{ s__('ContinuousDeployment|Cluster agent') }}</span>
        <span class="gl-font-monospace">{{ $options.mockCard.clusterAgent }}</span>
      </div>
    </div>
  </div>
</template>
