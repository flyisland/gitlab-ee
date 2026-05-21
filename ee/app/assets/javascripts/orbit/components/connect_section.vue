<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon, GlLink, GlModalDirective } from '@gitlab/ui';
import { DOCS_URL } from '~/constants';
import { __, s__ } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { visitUrl } from '~/lib/utils/url_utility';
import { buildApiUrl } from '~/api/api_utils';
import { fetchOrbitTools } from '../api/orbit_api';
import McpConfigModal from './mcp_config_modal.vue';
import ConnectExternalTools from './connect_external_tools.vue';

const SUGGESTED_QUERIES = [
  s__('Orbit|Show me recent merge requests with failing pipelines'),
  s__('Orbit|What open vulnerabilities exist in my projects?'),
  s__('Orbit|Who merged the most this quarter?'),
  s__('Orbit|List pipelines that failed in the last week'),
];

const DUO_VALUE_BULLETS = [
  {
    headline: s__('Orbit|Deeper intelligence, not just faster responses'),
    body: s__(
      "Orbit|Duo agents reason about how your code, pipelines, issues, and MRs actually connect — not just what's in a single file or prompt.",
    ),
  },
  {
    headline: s__('Orbit|Agents that know your codebase like your team does'),
    body: s__(
      'Orbit|The Knowledge Graph gives agents the relationship context they need to make recommendations grounded in how your team actually works.',
    ),
  },
  {
    headline: s__('Orbit|Less context-switching, more flow'),
    body: s__(
      'Orbit|Instead of manually gathering context before asking an agent for help, the Knowledge Graph provides that connective tissue automatically.',
    ),
  },
  {
    headline: s__('Orbit|Smarter over time'),
    body: s__(
      'Orbit|Every merge request, resolved incident, and linked issue enriches the graph, so Duo agents get progressively more intelligent about your organization.',
    ),
  },
];

const mcpEndpoint = `${window.location.origin}${buildApiUrl('/api/:version/orbit/mcp')}`;

const i18n = {
  connectTitle: s__('Orbit|Connect to Orbit'),
  connectSubtitle: s__(
    'Orbit|Give your tools the full picture. Orbit gives your AI tools structured access to how your organization builds software in GitLab, from code and history to plans and standards, so agents return answers that are more accurate and more efficient.',
  ),
  tryAsking: s__('Orbit|Try asking'),
  docs: s__('Orbit|Learn more about Orbit'),
  close: __('Close'),
  duoSectionTitle: s__('Orbit|Use Orbit with GitLab Duo'),
  duoSectionSubhead: s__('Orbit|GitLab Duo will use Orbit to provide enhanced intelligence.'),
};

export default defineComponent({
  name: 'ConnectSection',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlIcon,
    GlLink,
    McpConfigModal,
    ConnectExternalTools,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    agenticChatAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['close'],
  mcpEndpoint,
  docsHref: `${DOCS_URL}/orbit/`,
  suggestedQueries: SUGGESTED_QUERIES,
  duoValueBullets: DUO_VALUE_BULLETS,
  i18n,
  data() {
    return {
      tools: [],
      modalInitialView: 'configure',
      mcpModalVisible: false,
    };
  },
  async mounted() {
    try {
      const { data } = await fetchOrbitTools();
      // /api/v4/orbit/tools returns a top-level array; older shapes wrap as
      // { tools: [...] }. Accept both so a backend tweak doesn't blank the UI.
      this.tools = Array.isArray(data) ? data : data?.tools || [];
    } catch (error) {
      Sentry.captureException(error);
    }
  },
  methods: {
    onSuggestionClick(query) {
      import('ee/ai/utils')
        .then(({ sendDuoChatCommand }) => {
          sendDuoChatCommand({
            question: query,
            resourceId: 'orbit-suggested-prompt',
            agenticPrompt: query,
            agent: { name: __('Orbit') },
          });
        })
        .catch(() => {
          visitUrl(`${DOCS_URL}/orbit/duo_chat/`);
        });
    },
    openConfigure() {
      this.modalInitialView = 'configure';
      this.mcpModalVisible = true;
    },
  },
});
</script>

<template>
  <div
    class="explorer-hero-banner gl-flex gl-flex-row gl-items-start gl-gap-3 gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-py-6 gl-pl-6 gl-pr-4"
    data-testid="connect-section"
  >
    <!-- Title row -->

    <div class="gl-flex gl-w-full gl-flex-col gl-gap-6 lg:gl-flex-row">
      <div class="gl-flex gl-items-start gl-gap-3 lg:gl-basis-1/3">
        <div>
          <h2 class="gl-heading-2 gl-mb-2">
            {{ $options.i18n.connectTitle }}
          </h2>
          <p class="gl-m-0 gl-text-lg gl-text-subtle">
            {{ $options.i18n.connectSubtitle }}
          </p>
          <gl-link :href="$options.docsHref" class="gl-mt-3 gl-inline-block">
            {{ $options.i18n.docs }}
          </gl-link>
        </div>
      </div>
      <div class="gl-flex gl-flex-col gl-gap-6 sm:gl-flex-row lg:gl-basis-2/3">
        <!-- Try asking suggestions -->
        <div class="gl-border gl-min-w-0 gl-flex-1 gl-rounded-lg gl-bg-default gl-p-5">
          <h3 class="gl-heading-4 gl-mb-2 gl-flex gl-items-center gl-gap-3">
            <gl-icon name="tanuki-ai" :size="16" />
            {{ $options.i18n.duoSectionTitle }}
          </h3>
          <p class="gl-text-subtle">
            {{ $options.i18n.duoSectionSubhead }}
          </p>
          <template v-if="agenticChatAvailable">
            <p
              class="gl-m-0 gl-mb-2 gl-flex gl-items-center gl-gap-2 gl-text-xs gl-font-semibold gl-uppercase gl-tracking-wider gl-text-subtle"
            >
              <gl-icon name="bulb" :size="12" />
              {{ $options.i18n.tryAsking }}
            </p>
            <div class="gl-flex gl-flex-col">
              <button
                v-for="(query, index) in $options.suggestedQueries"
                :key="index"
                class="gl-flex gl-w-full gl-cursor-pointer gl-items-center gl-self-start gl-border-0 gl-bg-transparent gl-px-2 gl-py-2 gl-text-left gl-text-sm gl-text-default hover:gl-bg-strong"
                :class="
                  index < $options.suggestedQueries.length - 1
                    ? 'gl-border-b gl-border-default'
                    : ''
                "
                data-testid="suggested-query"
                @click="onSuggestionClick(query)"
              >
                {{ query }}
              </button>
            </div>
          </template>
          <ul v-else class="gl-m-0 gl-flex gl-list-disc gl-flex-col gl-gap-3 gl-pl-5">
            <li
              v-for="(bullet, index) in $options.duoValueBullets"
              :key="index"
              class="gl-text-sm gl-text-default"
              data-testid="duo-value-bullet"
            >
              <strong>{{ bullet.headline }}</strong> — {{ bullet.body }}
            </li>
          </ul>
        </div>

        <connect-external-tools @quick-start="openConfigure" />
      </div>
    </div>
    <gl-button
      size="small"
      category="tertiary"
      icon="close"
      :aria-label="$options.i18n.close"
      data-testid="connect-close"
      @click="$emit('close')"
    />
    <mcp-config-modal
      :visible="mcpModalVisible"
      :mcp-endpoint="$options.mcpEndpoint"
      :tools="tools"
      :initial-view="modalInitialView"
      @change="mcpModalVisible = $event"
    />
  </div>
</template>
