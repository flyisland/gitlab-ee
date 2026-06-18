<script>
import { humanize } from '~/lib/utils/text_utility';
import { s__, sprintf } from '~/locale';
import { MESSAGE_SUB_TYPE_DELEGATION } from 'ee/ai/duo_agents_platform/constants';

export default {
  name: 'DelegationEntry',
  props: {
    item: {
      type: Object,
      required: true,
    },
    delegationData: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    isDelegation() {
      return this.item.messageSubType === MESSAGE_SUB_TYPE_DELEGATION;
    },
    capitalizedComponentName() {
      return humanize(this.item.componentName || 'subagent');
    },
    componentWithSession() {
      return this.item.subsessionId
        ? `${this.capitalizedComponentName} (${this.item.subsessionId})`
        : this.capitalizedComponentName;
    },
    delegatedTargetName() {
      return this.delegationData?.subagentName ? humanize(this.delegationData.subagentName) : null;
    },
    delegatedTargetWithSession() {
      if (!this.delegatedTargetName) return null;
      const id = this.delegationData?.subsessionId;
      return id ? `${this.delegatedTargetName} (${id})` : this.delegatedTargetName;
    },
    isFailureReturn() {
      return !this.isDelegation && this.item.status === 'failure';
    },
    delegationPrefix() {
      return sprintf(s__('DuoAgentPlatform|Delegated to %{target} \u2014'), {
        target: this.delegatedTargetWithSession,
      });
    },
    returnPrefix() {
      return sprintf(s__('DuoAgentPlatform|%{component} returned \u2014'), {
        component: this.componentWithSession,
      });
    },
    failureText() {
      return sprintf(s__('DuoAgentPlatform|%{component} did not produce an answer'), {
        component: this.componentWithSession,
      });
    },
  },
};
</script>

<template>
  <p
    class="gl-m-0 gl-flex gl-min-w-0 gl-items-center gl-gap-1 gl-py-2"
    data-testid="delegation-entry"
  >
    <template v-if="isFailureReturn">
      <span class="gl-text-danger" data-testid="delegation-entry-failure">{{ failureText }}</span>
    </template>

    <template v-else-if="isDelegation && !delegatedTargetWithSession">
      <span data-testid="delegation-entry-fallback">{{
        s__('DuoAgentPlatform|Delegated to subagent')
      }}</span>
    </template>

    <template v-else>
      <span data-testid="delegation-entry-prefix">{{
        isDelegation ? delegationPrefix : returnPrefix
      }}</span>
      <span class="gl-flex-1 gl-truncate" data-testid="delegation-entry-truncated-content">{{
        isDelegation ? delegationData.prompt : item.content
      }}</span>
    </template>
  </p>
</template>
