<script>
import {
  GlAlert,
  GlBadge,
  GlButton,
  GlExperimentBadge,
  GlLoadingIcon,
  GlSprintf,
} from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { createAlert } from '~/alert';
import { __, s__, sprintf } from '~/locale';
import { visitUrl } from '~/lib/utils/url_utility';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import { ACTIONS } from '../../catalog/actions';
import { RULES } from '../../catalog/rules';
import { TRIGGERS } from '../../catalog/triggers';
import { resolveCatalogEntry } from '../../catalog/helpers';
import {
  NAMESPACE_TYPE_GROUP,
  POLICY_STATUS_ACTIVE,
  POLICY_STATUS_DISABLED,
} from '../../constants';
import { policyMutationVariables } from '../../policies';
import { apiErrorMessage, readMutationPayload } from '../../utils';
import singlePolicyQuery from '../../single_policy_query';
import governPolicyUpdateMutation from '../../graphql/govern_policy_update.mutation.graphql';
import governPolicyDeleteMutation from '../../graphql/govern_policy_delete.mutation.graphql';
import { deserializePolicyData } from '../editor/serializer';
import { modeLabel, modeVariant, statusLabel, statusVariant, scopeLabel } from '../list/utils';
import SummarySection from './summary_section.vue';

export default {
  name: 'PolicyStoreDetailRoot',
  components: {
    GlAlert,
    GlBadge,
    GlButton,
    GlExperimentBadge,
    GlLoadingIcon,
    GlSprintf,
    SummarySection,
    TimeAgoTooltip,
  },
  i18n: {
    deleteConfirmButton: __('Delete'),
  },
  inject: {
    organizationId: {},
    namespacePath: { default: '' },
    namespaceType: {},
    policyId: {},
    listPath: { default: '' },
    editPath: { default: '' },
  },
  data() {
    return {
      policy: null,
      policyError: false,
      deleting: false,
      toggling: false,
    };
  },
  apollo: {
    policy: singlePolicyQuery,
  },
  computed: {
    policyLoading() {
      return this.$apollo.queries.policy.loading;
    },
    isGroupContext() {
      return this.namespaceType === NAMESPACE_TYPE_GROUP;
    },
    namespaceIdentifier() {
      return this.isGroupContext ? this.namespacePath : this.organizationId;
    },
    isActive() {
      return this.policy.status === POLICY_STATUS_ACTIVE;
    },
    versionLabel() {
      return sprintf(s__('PolicyStore|Version %{version}'), {
        version: this.policy.version,
      });
    },
    hasMeta() {
      return Boolean(this.policy.version || this.policy.created_at || this.policy.updated_at);
    },
    regoSections() {
      return [
        {
          testid: 'scope-rego',
          label: s__('PolicyStore|Compiled scope Rego'),
          help: s__(
            'PolicyStore|Read-only Rego the store compiled from the scope. The policy engine evaluates this program to decide where the policy applies.',
          ),
          rego: this.policy.scope_rego,
        },
        {
          testid: 'policy-rego',
          label: s__('PolicyStore|Compiled policy Rego'),
          help: s__(
            'PolicyStore|Read-only Rego the store compiled from the rules. The policy engine evaluates this single program when the trigger fires.',
          ),
          rego: this.policy.policy_rego,
        },
      ].filter(({ rego }) => rego);
    },
    toggleStatusLabel() {
      return this.isActive ? s__('PolicyStore|Disable') : s__('PolicyStore|Enable');
    },
    // The catalog files supply the presentation for the persisted ids, the same
    // lookup the editor and the list use.
    sections() {
      const { trigger, triggerConfig, rules, ruleConfigs, actions, actionConfigs } =
        deserializePolicyData(this.policy);

      return [
        {
          testid: 'trigger',
          label: s__('PolicyStore|Trigger'),
          ids: trigger ? [trigger] : [],
          catalog: TRIGGERS,
          configs: { [trigger]: triggerConfig },
        },
        {
          testid: 'rules',
          label: s__('PolicyStore|Rules'),
          ids: rules,
          catalog: RULES,
          configs: ruleConfigs,
        },
        {
          testid: 'actions',
          label: s__('PolicyStore|Actions'),
          ids: actions,
          catalog: ACTIONS,
          configs: actionConfigs,
        },
      ].map(({ testid, label, ids, catalog, configs }) => ({
        testid,
        label,
        entries: ids.map((id) => resolveCatalogEntry(catalog, id, configs[id])),
      }));
    },
  },
  methods: {
    modeLabel,
    modeVariant,
    statusLabel,
    statusVariant,
    scopeLabel,
    mutationVariables(document, params) {
      return policyMutationVariables({
        document,
        namespaceType: this.namespaceType,
        namespaceIdentifier: this.namespaceIdentifier,
        policyId: this.policyId,
        params,
      });
    },
    // The mutation returns the whole policy, which Apollo normalizes onto the
    // entity this page's query watches, so the badges refresh from the cache
    // without a second read.
    async onToggleStatus() {
      this.toggling = true;

      const lifecycleState = this.isActive ? POLICY_STATUS_DISABLED : POLICY_STATUS_ACTIVE;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: governPolicyUpdateMutation,
          variables: this.mutationVariables(governPolicyUpdateMutation, {
            lifecycle_state: lifecycleState,
          }),
        });

        readMutationPayload(data, 'governPolicyUpdate');
      } catch (error) {
        Sentry.captureException(error);
        createAlert({
          message:
            apiErrorMessage(error) ||
            s__('PolicyStore|The policy could not be updated. Try again.'),
        });
      } finally {
        this.toggling = false;
      }
    },
    async onDelete() {
      // Guards re-entrancy: the confirm dialog is awaited before any request,
      // so without this a double-click would open two confirmation flows.
      if (this.deleting) return;

      this.deleting = true;

      const confirmed = await confirmAction(
        sprintf(
          s__('PolicyStore|Are you sure you want to delete %{name}? This action cannot be undone.'),
          { name: this.policy.name },
        ),
        {
          title: s__('PolicyStore|Delete policy?'),
          primaryBtnText: this.$options.i18n.deleteConfirmButton,
          primaryBtnVariant: 'danger',
        },
      );

      if (!confirmed) {
        this.deleting = false;
        return;
      }

      try {
        // No cache update: with a list path the full navigation discards the
        // cache; without one the page keeps its last read, as it did before.
        const { data } = await this.$apollo.mutate({
          mutation: governPolicyDeleteMutation,
          variables: this.mutationVariables(governPolicyDeleteMutation),
        });

        readMutationPayload(data, 'governPolicyDelete');

        if (this.listPath) {
          visitUrl(this.listPath);
        } else {
          this.deleting = false;
        }
      } catch (error) {
        Sentry.captureException(error);
        createAlert({
          message:
            apiErrorMessage(error) ||
            s__('PolicyStore|The policy could not be deleted. Try again.'),
        });
        this.deleting = false;
      }
    },
  },
};
</script>

<template>
  <gl-loading-icon v-if="policyLoading" size="lg" class="gl-mt-6" data-testid="policy-loading" />
  <!-- A null policy after loading means not found: unknown id, denied read, or a skipped id. -->
  <gl-alert
    v-else-if="policyError || !policy"
    variant="danger"
    :dismissible="false"
    class="gl-mt-4"
    data-testid="policy-error"
  >
    {{
      s__(
        'PolicyStore|The policy could not be loaded from the Policy Store API. Refresh the page to try again.',
      )
    }}
  </gl-alert>
  <div v-else class="gl-flex gl-flex-col gl-gap-5 gl-pt-6">
    <div class="gl-flex gl-flex-wrap gl-items-start gl-justify-between gl-gap-4">
      <div class="gl-min-w-0">
        <div class="gl-mb-2 gl-flex gl-items-center">
          <h1 class="gl-heading-1 gl-mb-0" data-testid="policy-name">{{ policy.name }}</h1>
          <gl-experiment-badge type="experiment" />
        </div>
        <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-2">
          <gl-badge variant="neutral" data-testid="policy-type">{{ policy.type }}</gl-badge>
          <gl-badge :variant="modeVariant(policy.mode)" data-testid="policy-mode">
            {{ modeLabel(policy.mode) }}
          </gl-badge>
          <gl-badge :variant="statusVariant(policy.status)" data-testid="policy-status">
            {{ statusLabel(policy.status) }}
          </gl-badge>
        </div>
        <p
          v-if="policy.description"
          class="gl-mb-0 gl-mt-3 gl-text-subtle"
          data-testid="policy-description"
        >
          {{ policy.description }}
        </p>
        <ul
          v-if="hasMeta"
          class="gl-mb-0 gl-mt-3 gl-flex gl-list-none gl-flex-wrap gl-gap-x-4 gl-gap-y-1 gl-p-0 gl-text-sm gl-text-subtle"
          data-testid="policy-meta"
        >
          <li v-if="policy.version" data-testid="policy-version">{{ versionLabel }}</li>
          <li v-if="policy.created_at" data-testid="policy-created-at">
            <gl-sprintf :message="s__('PolicyStore|Created %{timeAgo}')">
              <template #timeAgo><time-ago-tooltip :time="policy.created_at" /></template>
            </gl-sprintf>
          </li>
          <li v-if="policy.updated_at" data-testid="policy-updated-at">
            <gl-sprintf :message="s__('PolicyStore|Updated %{timeAgo}')">
              <template #timeAgo><time-ago-tooltip :time="policy.updated_at" /></template>
            </gl-sprintf>
          </li>
        </ul>
      </div>
      <div class="gl-flex gl-flex-shrink-0 gl-gap-3">
        <gl-button :href="editPath" data-testid="edit-policy-button">
          {{ s__('PolicyStore|Edit policy') }}
        </gl-button>
        <gl-button :loading="toggling" data-testid="toggle-status-button" @click="onToggleStatus">
          {{ toggleStatusLabel }}
        </gl-button>
        <gl-button
          category="secondary"
          variant="danger"
          :loading="deleting"
          data-testid="delete-policy-button"
          @click="onDelete"
        >
          {{ $options.i18n.deleteConfirmButton }}
        </gl-button>
      </div>
    </div>

    <summary-section
      v-for="section in sections"
      :key="section.testid"
      :label="section.label"
      :entries="section.entries"
      :testid="section.testid"
    />

    <summary-section :label="s__('PolicyStore|Scope')" testid="scope">
      <p class="gl-mb-0">{{ scopeLabel(policy.scopedProjectsCount) }}</p>
    </summary-section>

    <summary-section
      v-for="rego in regoSections"
      :key="rego.testid"
      :label="rego.label"
      :testid="rego.testid"
    >
      <p class="gl-mb-3 gl-text-sm gl-text-subtle">{{ rego.help }}</p>
      <pre
        tabindex="0"
        role="region"
        :aria-label="rego.label"
        class="gl-mb-0 gl-max-h-48 gl-overflow-y-auto gl-whitespace-pre-wrap gl-rounded-base gl-bg-subtle gl-p-3 gl-text-sm"
      ><code>{{ rego.rego }}</code></pre>
    </summary-section>
  </div>
</template>
