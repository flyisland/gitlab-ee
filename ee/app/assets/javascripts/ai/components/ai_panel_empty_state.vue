<script>
import {
  GlButton,
  GlLink,
  GlCard,
  GlIcon,
  GlAvatarLabeled,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/src/utils'; // eslint-disable-line no-restricted-syntax -- GlBreakpointInstance is used intentionally here. In this case we must obtain viewport breakpoints
import tanukiAiSvgUrl from '@gitlab/svgs/dist/illustrations/tanuki-ai-sm.svg?url';
import securityAgentAvatarUrl from 'ee_images/bot_avatars/security-agent.png';
import plannerAgentAvatarUrl from 'ee_images/bot_avatars/planner-agent.png';
import analyticsAgentAvatarUrl from 'ee_images/bot_avatars/analytics-agent.png';
import { __, s__ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import { InternalEvents } from '~/tracking';
import { TYPENAME_GROUP } from '~/graphql_shared/constants';
import dismissUserCalloutMutation from '~/graphql_shared/mutations/dismiss_user_callout.mutation.graphql';
import { BV_HIDE_TOOLTIP } from '~/lib/utils/constants';
import { DUO_PANEL_EMPTY_STATE_EVENTS } from '../constants';

const DUO_PANEL_AUTO_EXPANDED_CALLOUT = 'duo_panel_empty_state_auto_expanded';

export default {
  name: 'AiPanelEmptyState',
  components: {
    GlButton,
    GlLink,
    GlCard,
    GlIcon,
    GlAvatarLabeled,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [InternalEvents.mixin()],
  inject: {
    autoExpand: { default: false },
    canStartTrial: { default: false },
    isTrialExpired: { default: false },
    newTrialPath: { default: '' },
    trialDuration: { default: '' },
    namespaceType: { default: '' },
    buyAddonPath: { default: '' },
    canBuyAddon: { default: false },
  },
  data() {
    const isDesktop = GlBreakpointInstance.isDesktop();
    const isExpanded = isDesktop && this.autoExpand;

    return {
      isDesktop,
      isExpanded,
    };
  },
  computed: {
    namespaceTypeLabel() {
      return this.namespaceType === TYPENAME_GROUP ? __('group') : __('project');
    },
    showUpgradeCta() {
      return this.canBuyAddon && this.buyAddonPath;
    },
  },
  mounted() {
    window.addEventListener('resize', this.handleWindowResize);
    if (this.isTrialExpired) {
      this.trackEvent(DUO_PANEL_EMPTY_STATE_EVENTS.VIEW_TRIAL_EXPIRED);
    } else {
      this.trackEvent(DUO_PANEL_EMPTY_STATE_EVENTS.VIEW_NOT_AVAILABLE);
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleWindowResize);
  },
  methods: {
    togglePanel() {
      if (this.isExpanded) {
        this.closePanel();
      } else {
        this.isExpanded = true;
      }
    },
    closePanel({ shouldDismissCallout = true } = {}) {
      this.isExpanded = false;
      if (shouldDismissCallout) {
        this.dismissAutoExpandCallout();
      }
    },
    async dismissAutoExpandCallout() {
      try {
        await this.$apollo.mutate({
          mutation: dismissUserCalloutMutation,
          variables: {
            input: {
              featureName: DUO_PANEL_AUTO_EXPANDED_CALLOUT,
            },
          },
        });
      } catch {
        // Silently ignore errors - callout dismissal is non-critical
      }
    },
    handleWindowResize() {
      const currentIsDesktop = GlBreakpointInstance.isDesktop();

      // This check ensures that the panel is collapsed only when resizing
      // from desktop to mobile/tablet, not the other way around
      if (this.isDesktop && !currentIsDesktop) {
        this.closePanel({ shouldDismissCallout: false });
      }

      this.isDesktop = currentIsDesktop;
    },
    hideTooltips() {
      this.$root.$emit(BV_HIDE_TOOLTIP);
    },
    onUpgradeClick() {
      this.trackEvent(DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_TRIAL_EXPIRED_UPGRADE);
    },
    onLearnMoreClick() {
      this.trackEvent(DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_TRIAL_EXPIRED_LEARN_MORE);
    },
  },
  tanukiAiSvgUrl,
  securityAgentAvatarUrl,
  plannerAgentAvatarUrl,
  analyticsAgentAvatarUrl,
  dapDocs: helpPagePath('/user/duo_agent_platform/_index.md'),
  trackingEvents: DUO_PANEL_EMPTY_STATE_EVENTS,
  workflowExamples: [
    {
      icon: 'merge-request',
      title: s__('DuoAgentsPlatform|Review a merge request'),
      subtitle: s__('DuoAgentsPlatform|Identify code improvements'),
    },
    {
      icon: 'pipeline',
      title: s__('DuoAgentsPlatform|Fix a failing pipeline'),
      subtitle: s__('DuoAgentsPlatform|Analyze pipeline failures and get fix suggestions'),
    },
  ],
  i18n: {
    expandButtonLabel: s__('DuoAgenticChat|GitLab Duo Agent Platform'),
    collapseButtonLabel: __('Collapse'),
    trialExpiredHeadline: s__('DuoAgenticChat|Your GitLab Duo Agent Platform trial has ended'),
    trialExpiredDescription: s__(
      'DuoAgenticChat|Your trial has ended. Repurchase to resume using GitLab Duo Agent Platform.',
    ),
    upgradeCta: s__('DuoAgenticChat|Upgrade to Premium'),
    learnMore: __('Learn more'),
  },
};
</script>

<!-- eslint-disable @gitlab/vue-tailwind-no-max-width-media-queries -->
<template>
  <div class="gl-flex gl-h-full gl-gap-[var(--ai-panels-gap)]">
    <aside
      v-if="isExpanded"
      data-testid="panel-content"
      class="ai-panel !gl-left-auto gl-flex gl-h-full gl-w-[var(--ai-panel-width)] gl-grow gl-flex-col gl-justify-center gl-rounded-[1rem] gl-bg-default [contain:strict] lg:gl-mr-2"
    >
      <div class="ai-panel-header gl-flex gl-h-[3.0625rem] gl-items-center gl-justify-end">
        <div class="ai-panel-header-actions gl-flex gl-gap-x-2 gl-pr-3">
          <gl-button
            v-gl-tooltip.bottom
            icon="dash"
            category="tertiary"
            size="small"
            :aria-label="$options.i18n.collapseButtonLabel"
            :title="$options.i18n.collapseButtonLabel"
            aria-expanded="true"
            data-testid="content-container-collapse-button"
            @click="closePanel"
          />
        </div>
      </div>
      <div
        :class="[
          'ai-panel-body gl-flex gl-w-full gl-grow gl-flex-col gl-items-start gl-gap-5 gl-overflow-auto gl-px-5 gl-pt-5',
          { 'gl-justify-center': isTrialExpired },
        ]"
      >
        <img :src="$options.tanukiAiSvgUrl" class="gl-h-10 gl-w-10" />
        <template v-if="isTrialExpired">
          <h2 class="gl-my-0 gl-text-size-h2">
            {{ $options.i18n.trialExpiredHeadline }}
          </h2>
          <p class="gl-m-0 gl-text-subtle" data-testid="empty-state-text">
            {{ $options.i18n.trialExpiredDescription }}
          </p>
          <div class="gl-flex gl-gap-3">
            <gl-button
              v-if="showUpgradeCta"
              variant="confirm"
              category="primary"
              :href="buyAddonPath"
              data-testid="upgrade-button"
              @click="onUpgradeClick"
            >
              {{ $options.i18n.upgradeCta }}
            </gl-button>
            <gl-button
              :href="$options.dapDocs"
              target="_blank"
              data-testid="learn-more-button"
              @click="onLearnMoreClick"
            >
              {{ $options.i18n.learnMore }}
            </gl-button>
          </div>
        </template>
        <template v-else-if="canStartTrial">
          <h2 class="gl-my-0 gl-text-size-h2">
            {{ s__('DuoAgentsPlatform|Try GitLab Duo Agent Platform') }}
          </h2>
          <p class="gl-m-0 gl-text-subtle" data-testid="empty-state-text">
            <gl-sprintf
              :message="
                s__(
                  'DuoAgentsPlatform|Start your free %{strongStart}%{trialDuration}-day trial%{strongEnd} now to accelerate your software delivery. Automate tasks with AI agents, from searching projects to creating commits.',
                )
              "
            >
              <template #strong="{ content }">
                <strong>{{ sprintf(content, { trialDuration }) }}</strong>
              </template>
            </gl-sprintf>
          </p>
          <div class="gl-flex gl-gap-3">
            <gl-button
              variant="confirm"
              category="primary"
              :href="newTrialPath"
              data-event-tracking="click_link"
              :data-event-label="$options.trackingEvents.CLICK_START_TRIAL"
              data-testid="start-trial-link"
            >
              {{ s__('DuoAgentsPlatform|Start a Free Trial') }}
            </gl-button>
            <gl-button
              variant="default"
              data-event-tracking="click_link"
              :data-event-label="$options.trackingEvents.CLICK_LEARN_MORE"
              data-testid="learn-more-link"
              :href="$options.dapDocs"
            >
              {{ __('Learn more') }}
            </gl-button>
          </div>
          <gl-card class="gl-mt-3 gl-w-full">
            <template #header>
              <span class="gl-font-bold">{{
                s__('DuoAgentsPlatform|Complete multi-step tasks with flows')
              }}</span>
            </template>
            <div class="gl-flex gl-flex-col gl-gap-4">
              <div
                v-for="(example, i) in $options.workflowExamples"
                :key="i"
                class="gl-flex gl-gap-x-2"
                data-testid="workflow-example"
              >
                <div><gl-icon :name="example.icon" /></div>
                <div>
                  <div class="gl-font-bold gl-text-strong">
                    {{ example.title }}
                  </div>
                  <div class="gl-text-subtle">{{ example.subtitle }}</div>
                </div>
              </div>
            </div>
          </gl-card>
          <h3 class="gl-heading-5 gl-m-0">
            {{ s__('DuoAgentsPlatform|Chat with a specialized agent') }}
          </h3>
          <p class="gl-m-0">
            {{
              s__(
                'DuoAgentsPlatform|With a trial you can chat with AI agents tailored to your development workflow, such as the following agents:',
              )
            }}
          </p>
          <div class="gl-flex gl-w-full gl-justify-start gl-gap-5 gl-pb-5">
            <gl-avatar-labeled
              :src="$options.securityAgentAvatarUrl"
              :size="32"
              :label="s__('DuoAgentsPlatform|Security Agent')"
              fallback-on-error
            />
            <gl-avatar-labeled
              :src="$options.plannerAgentAvatarUrl"
              :size="32"
              :label="s__('DuoAgentsPlatform|Planning Agent')"
              fallback-on-error
            />
            <gl-avatar-labeled
              :src="$options.analyticsAgentAvatarUrl"
              :size="32"
              :label="s__('DuoAgentsPlatform|Data Analyst')"
              fallback-on-error
            />
          </div>
        </template>
        <template v-else>
          <h2 class="gl-my-0 gl-text-size-h2">
            {{ s__('DuoAgentsPlatform|Access required') }}
          </h2>
          <p class="gl-m-0 gl-text-subtle" data-testid="empty-state-text">
            <gl-sprintf
              :message="
                s__(
                  `DuoAgentsPlatform|You don't have permission to use GitLab Duo Agent Platform in this %{namespaceType}. %{learnMoreLinkStart}Learn more%{learnMoreLinkEnd}.`,
                )
              "
            >
              <template #namespaceType>{{ namespaceTypeLabel }}</template>
              <template #learnMoreLink="{ content }">
                <gl-link
                  target="_blank"
                  :href="$options.dapDocs"
                  data-event-tracking="click_link"
                  :data-event-label="$options.trackingEvents.CLICK_LEARN_MORE"
                  data-testid="learn-more-link"
                  >{{ content }}</gl-link
                >
              </template>
            </gl-sprintf>
          </p>
          <gl-card class="gl-mt-3 gl-w-full">
            <template #header>
              <span class="gl-font-bold">{{
                s__('DuoAgentsPlatform|Get access to GitLab Duo')
              }}</span>
            </template>
            <div class="gl-flex gl-flex-col gl-gap-4">
              <div class="gl-flex gl-gap-x-2">
                <div><gl-icon name="user" /></div>
                <div>
                  <div class="gl-font-bold gl-text-strong">
                    {{ s__('DuoAgentsPlatform|Who can grant you access') }}
                  </div>
                  <div class="gl-text-subtle">
                    {{ s__('DuoAgentsPlatform|Contact a project Maintainer or group Owner') }}
                  </div>
                </div>
              </div>
            </div>
          </gl-card>
        </template>
      </div>
    </aside>
    <nav :aria-label="__('Duo controls')">
      <div
        class="gl-ml-3 gl-flex gl-items-center gl-gap-5 gl-bg-transparent max-lg:gl-h-[var(--ai-navigation-rail-size)] max-lg:gl-flex-1 max-lg:gl-px-3 max-sm:gl-px-0 sm:gl-ml-0 lg:gl-mt-2 lg:gl-w-[var(--ai-navigation-rail-size)] lg:gl-flex-col lg:gl-gap-4 lg:gl-py-3"
        role="tablist"
        aria-orientation="vertical"
      >
        <gl-button
          v-gl-tooltip.left
          icon="duo-chat-off"
          size="small"
          :aria-label="$options.i18n.expandButtonLabel"
          :title="$options.i18n.expandButtonLabel"
          :class="['ai-nav-icon', { 'ai-nav-icon-active': isExpanded }]"
          data-testid="toggle-panel-content-button"
          role="tab"
          @click="togglePanel"
          @mouseout="hideTooltips"
        />
      </div>
    </nav>
  </div>
</template>
