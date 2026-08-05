<script>
import { GlAlert, GlAvatar, GlTooltipDirective } from '@gitlab/ui';
import { DUO_CHAT_VIEWS } from 'ee/ai/constants';
import { s__ } from '~/locale';
import SafeHtml from '~/vue_shared/directives/safe_html';

export const i18n = {
  CHAT_TITLE: s__('DuoChat|GitLab Duo Chat'),
};

export default {
  name: 'DuoChatHeader',
  components: {
    GlAlert,
    GlAvatar,
  },
  directives: {
    SafeHtml,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: i18n.CHAT_TITLE,
    },
    error: {
      type: String,
      required: false,
      default: '',
    },
    info: {
      type: String,
      required: false,
      default: '',
    },
    currentView: {
      type: String,
      required: true,
    },
  },
  computed: {
    showSubheader() {
      return this.currentView !== DUO_CHAT_VIEWS.LIST;
    },
  },
  i18n,
};
</script>

<template>
  <header
    data-testid="chat-header"
    class="gl-sticky gl-top-0 gl-z-9999 gl-shrink-0 gl-bg-default gl-p-0"
  >
    <div
      v-if="showSubheader"
      class="drawer-title gl-border-b gl-flex gl-items-center gl-justify-start gl-gap-4 gl-px-4 gl-pb-2 gl-pt-2"
      data-testid="chat-subheader"
    >
      <div class="gl-flex gl-grow gl-items-center gl-gap-3">
        <gl-avatar :size="32" :entity-name="title" shape="circle" class="gl-shrink-0" />
        <div class="gl-flex gl-flex-col gl-justify-center">
          <h3 class="gl-my-0 gl-line-clamp-1 gl-text-[0.875rem] gl-text-default gl-break-anywhere">
            {{ title }}
          </h3>
        </div>
      </div>
      <div class="gl-flex gl-gap-3">
        <slot name="subheader"></slot>
      </div>
    </div>

    <gl-alert
      v-if="info"
      key="info"
      :dismissible="false"
      variant="info"
      class="!gl-pl-9"
      role="alert"
      data-testid="chat-info"
    >
      <span v-safe-html="info"></span>
    </gl-alert>

    <gl-alert
      v-if="error"
      key="error"
      :dismissible="false"
      variant="danger"
      class="!gl-pl-9"
      role="alert"
      data-testid="chat-error"
    >
      <span v-safe-html="error"></span>
    </gl-alert>
  </header>
</template>
