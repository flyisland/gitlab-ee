<script>
import { GlButton, GlIcon, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { s__ } from '~/locale';
import { eventHub, SHOW_SESSION } from 'ee/ai/events/panel';
import duoChatAvailableQuery from '../../graphql/duo_chat_available.query.graphql';
import { INITIATOR_USER, INITIATOR_TRIGGER, INITIATOR_NONE } from './constants';

export default {
  name: 'AgentActorLine',
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    agentName: {
      type: String,
      required: false,
      default: '',
    },
    sessionId: {
      type: [String, Number],
      required: true,
    },
    canViewSession: {
      type: Boolean,
      required: true,
    },
    agentCatalogPath: {
      type: String,
      required: false,
      default: '',
    },
    initiatorType: {
      type: String,
      required: false,
      default: INITIATOR_NONE,
      validator: (value) => [INITIATOR_USER, INITIATOR_TRIGGER, INITIATOR_NONE].includes(value),
    },
    initiator: {
      type: Object,
      required: false,
      default: null,
    },
    withAgentName: {
      type: Boolean,
      required: false,
      default: false,
    },
    withInitiator: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      duoChatAvailable: false,
    };
  },
  apollo: {
    duoChatAvailable: {
      query: duoChatAvailableQuery,
      update(data) {
        return data?.currentUser?.duoChatAvailable ?? false;
      },
      error() {
        this.duoChatAvailable = false;
      },
    },
  },
  computed: {
    numericSessionId() {
      return getIdFromGraphQLId(this.sessionId);
    },
    canOpenSession() {
      return this.canViewSession && this.duoChatAvailable;
    },
    checkingSessionAccess() {
      return this.canViewSession && this.$apollo.queries.duoChatAvailable.loading;
    },
    unavailableSessionTooltip() {
      return this.canViewSession
        ? s__('DuoAgentPlatform|GitLab Duo Agent Platform is not available.')
        : s__('DuoAgentPlatform|You do not have access to this session.');
    },
    initiatorUserPopoverAttributes() {
      const { userId, username } = this.initiator ?? {};
      if (this.initiatorType !== INITIATOR_USER || !userId) return {};

      return {
        class: 'js-user-link',
        'data-user-id': getIdFromGraphQLId(userId),
        'data-username': username,
      };
    },
    showInitiator() {
      const labeled =
        [INITIATOR_USER, INITIATOR_TRIGGER].includes(this.initiatorType) &&
        Boolean(this.initiator?.label);

      return labeled && this.withInitiator;
    },
    message() {
      if (this.showInitiator) {
        if (this.initiatorType === INITIATOR_TRIGGER) {
          return this.withAgentName
            ? s__(
                'DuoAgentPlatform|%{linkStart}Session%{linkEnd} by %{agentName} triggered by %{initiatorName}',
              )
            : s__('DuoAgentPlatform|%{linkStart}Session%{linkEnd} triggered by %{initiatorName}');
        }

        return this.withAgentName
          ? s__(
              'DuoAgentPlatform|%{linkStart}Session%{linkEnd} by %{agentName} on behalf of %{initiatorName}',
            )
          : s__('DuoAgentPlatform|%{linkStart}Session%{linkEnd} on behalf of %{initiatorName}');
      }

      return this.withAgentName
        ? s__('DuoAgentPlatform|%{linkStart}Session%{linkEnd} by %{agentName}')
        : s__('DuoAgentPlatform|%{linkStart}Session%{linkEnd}');
    },
  },
  methods: {
    openSession() {
      eventHub.$emit(SHOW_SESSION, { id: this.numericSessionId });
    },
  },
};
</script>

<template>
  <span class="gl-text-subtle">
    <gl-sprintf :message="message">
      <template #link="{ content }">
        <gl-button
          v-if="canOpenSession"
          variant="link"
          class="gl-align-text-bottom !gl-text-inherit hover:!gl-text-link"
          data-testid="session-button"
          @click="openSession"
        >
          <gl-icon name="session-ai" :size="12" class="gl-align-text-bottom" />
          {{ content }}
        </gl-button>
        <span v-else-if="checkingSessionAccess" data-testid="session-pending">
          <gl-icon name="session-ai" :size="12" class="gl-align-text-bottom" />
          {{ content }}
        </span>
        <span
          v-else
          v-gl-tooltip
          :title="unavailableSessionTooltip"
          tabindex="0"
          class="gl-text-disabled"
          data-testid="session-no-access"
        >
          <gl-icon name="session-ai" :size="12" variant="disabled" class="gl-align-text-bottom" />
          {{ content }}
        </span>
      </template>

      <template #agentName>
        <gl-link
          v-if="agentCatalogPath"
          :href="agentCatalogPath"
          variant="meta"
          class="gl-button-text !gl-text-inherit hover:!gl-text-link"
          data-testid="agent-link"
          >{{ agentName }}</gl-link
        >
        <span v-else class="gl-button-text" data-testid="agent-name">{{ agentName }}</span>
      </template>

      <template #initiatorName>
        <gl-link
          v-if="initiator.webPath"
          v-bind="initiatorUserPopoverAttributes"
          :href="initiator.webPath"
          variant="meta"
          class="gl-button-text !gl-text-inherit hover:!gl-text-link"
          data-testid="initiator-link"
          >{{ initiator.label }}</gl-link
        >
        <span v-else class="gl-button-text" data-testid="initiator-name">{{
          initiator.label
        }}</span>
      </template>
    </gl-sprintf>
  </span>
</template>
