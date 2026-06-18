<script>
import emptyEnvironmentsSvgPath from '@gitlab/svgs/dist/illustrations/empty-state/empty-environment-md.svg';
import { GlButton, GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'EnvironmentList',
  components: {
    GlButton,
    GlEmptyState,
  },
  i18n: {
    emptyStateTitle: s__('ContinuousDeployment|Get started with environments'),
    emptyStateDescription: s__(
      'ContinuousDeployment|Environments are places where code gets deployed, such as staging or production.',
    ),
    registerFirstEnvironment: s__('ContinuousDeployment|Register your first environment'),
  },
  emptyEnvironmentsSvgPath,
};
</script>

<template>
  <div>
    <gl-empty-state
      :title="$options.i18n.emptyStateTitle"
      :description="$options.i18n.emptyStateDescription"
      :svg-path="$options.emptyEnvironmentsSvgPath"
    >
      <template #actions>
        <gl-button variant="confirm" data-testid="register-first-environment-button">
          {{ $options.i18n.registerFirstEnvironment }}
        </gl-button>
      </template>
    </gl-empty-state>
  </div>
</template>
