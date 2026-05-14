<script>
import { GlButton } from '@gitlab/ui';
import tanukiAiSvgUrl from '@gitlab/svgs/dist/illustrations/tanuki-ai-sm.svg?url';

export default {
  name: 'ThreadExpiredEmptyState',
  components: {
    GlButton,
  },
  emits: ['back-to-list', 'new-chat'],
  tanukiAiSvgUrl,
};
</script>

<template>
  <div
    class="gl-flex gl-w-full gl-flex-col gl-items-start gl-gap-4 gl-py-8"
    data-testid="thread-expired-empty-state"
  >
    <img
      :src="$options.tanukiAiSvgUrl"
      class="gl-h-10 gl-w-10"
      :alt="s__('DuoAgenticChat|GitLab Duo AI assistant')"
    />
    <h2 class="gl-heading-2 gl-mb-0">
      {{ s__('DuoAgenticChat|This conversation has expired') }}
    </h2>
    <p class="gl-text-subtle">
      {{
        s__(
          'DuoAgenticChat|Conversations expire after more than 30 days of inactivity. Start a new conversation, or select an active conversation from your chat history.',
        )
      }}
    </p>
    <div class="gl-flex gl-flex-wrap gl-gap-3">
      <gl-button data-testid="back-to-threads-button" @click="$emit('back-to-list')">
        {{ s__('DuoAgenticChat|Go to your chat history') }}
      </gl-button>
      <gl-button
        variant="confirm"
        category="primary"
        data-testid="new-conversation-button"
        @click="$emit('new-chat')"
      >
        {{ s__('DuoAgenticChat|Start a new conversation') }}
      </gl-button>
    </div>
  </div>
</template>
