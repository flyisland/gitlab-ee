<script>
import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import mergeChecksQuery from '~/vue_merge_request_widget/queries/merge_checks.query.graphql';
import mergeChecksSubscription from '~/vue_merge_request_widget/queries/merge_checks.subscription.graphql';
import { TYPENAME_MERGE_REQUEST } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { SECURITY_POLICY_PIPELINE_CHECK, BLOCKING_STATUSES } from './checks/constants';

export default {
  name: 'MrWidgetSecurityPolicyPipelineNote',
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
  apollo: {
    mergeChecksState: {
      query: mergeChecksQuery,
      skip() {
        return !this.mr?.securityPoliciesPath;
      },
      variables() {
        return {
          projectPath: this.mr.targetProjectFullPath,
          iid: `${this.mr.iid}`,
        };
      },
      update(data) {
        return data?.project?.mergeRequest?.mergeabilityChecks || [];
      },
      error() {
        this.mergeChecksState = [];
      },
      subscribeToMore: {
        document() {
          return mergeChecksSubscription;
        },
        skip() {
          return !this.mr?.id;
        },
        variables() {
          return {
            issuableId: convertToGraphQLId(TYPENAME_MERGE_REQUEST, this.mr?.id),
          };
        },
        updateQuery(
          _,
          {
            subscriptionData: {
              data: { mergeRequestMergeStatusUpdated },
            },
          },
        ) {
          if (mergeRequestMergeStatusUpdated) {
            this.mergeChecksState = mergeRequestMergeStatusUpdated?.mergeabilityChecks || [];
          }
        },
      },
    },
  },
  data() {
    return {
      mergeChecksState: [],
    };
  },
  computed: {
    securityPolicyPipelineCheck() {
      return (
        this.mergeChecksState.find((c) => c.identifier === SECURITY_POLICY_PIPELINE_CHECK) || null
      );
    },
    isSecurityPolicyPipelineCheckBlocking() {
      return BLOCKING_STATUSES.includes(this.securityPolicyPipelineCheck?.status);
    },
    shouldShow() {
      return Boolean(
        this.mr?.isPipelinePassing &&
          this.isSecurityPolicyPipelineCheckBlocking &&
          this.mr?.securityPoliciesPath,
      );
    },
  },
  i18n: {
    message: s__(
      'mrWidget|Merge request pipeline has passed, but a security policy requires all pipelines to succeed. Another pipeline for this commit has failed. %{linkStart}View policies%{linkEnd}',
    ),
  },
};
</script>

<template>
  <div
    v-if="shouldShow"
    class="mr-section-container mr-widget-security-policy-pipeline-note !gl-mt-0 gl-flex gl-items-center gl-gap-3 !gl-rounded-t-none !gl-border-t-0 gl-bg-subtle gl-px-5 gl-py-3 gl-text-sm gl-text-subtle"
    data-testid="security-policy-pipeline-note"
  >
    <gl-icon name="status-alert" :size="16" variant="warning" class="gl-shrink-0" />
    <p class="gl-mb-0">
      <gl-sprintf :message="$options.i18n.message">
        <template #link="{ content }">
          <gl-link :href="mr.securityPoliciesPath" data-testid="view-policies-link">{{
            content
          }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
  </div>
</template>
