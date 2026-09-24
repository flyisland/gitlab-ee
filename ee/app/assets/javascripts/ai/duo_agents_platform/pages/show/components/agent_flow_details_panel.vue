<script>
import {
  GlAttributeList,
  GlBadge,
  GlIcon,
  GlIntersperse,
  GlLink,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { ciJobsLabel } from 'ee/ai/duo_agents_platform/utils';
import AgentFlowTriggeredUser from '../../../components/common/agent_flow_triggered_user.vue';

export default {
  name: 'AgentFlowDetailsPanel',
  components: {
    GlAttributeList,
    GlBadge,
    GlIcon,
    GlIntersperse,
    GlLink,
    AgentFlowTriggeredUser,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    sessionId: {
      type: String,
      required: true,
    },
    sessionUrl: {
      type: String,
      required: false,
      default: '',
    },
    flowName: {
      type: String,
      required: true,
    },
    flowPath: {
      type: String,
      required: false,
      default: '',
    },
    project: {
      type: Object,
      required: true,
    },
    user: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    createdAt: {
      type: String,
      required: false,
      default: null,
    },
    updatedAt: {
      type: String,
      required: false,
      default: null,
    },
    modelName: {
      type: String,
      required: false,
      default: '',
    },
    modelIdentifier: {
      type: String,
      required: false,
      default: '',
    },
    jobItems: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    sections() {
      return [
        {
          label: s__('DuoAgentsPlatform|Identity'),
          rows: [
            {
              label: s__('DuoAgentsPlatform|Session'),
              text: this.sessionId,
              link: this.sessionUrl || null,
              icon: 'session-ai',
            },
            {
              label: s__('AI|Flow'),
              text: this.flowName,
              link: this.flowPath || null,
            },
            {
              label: __('Project'),
              text: this.project?.name || __('None'),
              link: this.project?.webPath || null,
              icon: 'project',
            },
            {
              label: __('Group'),
              text: this.project?.namespace?.name || __('None'),
              link: this.project?.namespace?.webPath || null,
              icon: 'group',
            },
          ],
        },
        {
          label: s__('DuoAgentsPlatform|Execution'),
          rows: [
            {
              label: __('Triggered by'),
              type: 'triggeredUser',
            },
            ...(this.createdAt ? [{ label: __('Started'), text: this.createdAt }] : []),
            ...(this.updatedAt ? [{ label: __('Last updated'), text: this.updatedAt }] : []),
          ],
        },
        {
          label: s__('DuoAgentsPlatform|Supplemental'),
          rows: [
            ...(this.modelName
              ? [
                  {
                    label: s__('DuoAgentsPlatform|Default model'),
                    type: 'model',
                    text: this.modelName,
                    tooltip: this.modelIdentifier,
                  },
                ]
              : []),
            {
              label: this.ciJobsLabel,
              type: 'jobItems',
              jobItems: this.jobItems,
            },
          ],
        },
      ];
    },
    ciJobsLabel() {
      return ciJobsLabel(this.jobItems.length);
    },
  },
};
</script>
<template>
  <gl-attribute-list
    :items="sections"
    layout="vertical"
    class="[&_.gl-attribute-list-item:last-child]:gl-border-b-0"
  >
    <template #label="{ item: section }">
      {{ section.label }}
    </template>
    <template #description="{ item: section }">
      <dl class="gl-m-0">
        <div
          v-for="row in section.rows"
          :key="row.label"
          class="gl-flex gl-flex-col gl-gap-2 gl-py-3"
          :data-testid="`row-${row.label}`"
        >
          <dt class="gl-text-sm gl-text-subtle">
            {{ row.label }}
          </dt>
          <dd class="gl-m-0" data-testid="detail-value">
            <agent-flow-triggered-user v-if="row.type === 'triggeredUser'" :user="user" />
            <span v-else-if="row.type === 'model'">
              <gl-badge
                v-gl-tooltip="row.tooltip"
                class="gl-font-monospace"
                data-testid="model-badge"
              >
                {{ row.text }}
              </gl-badge>
            </span>
            <span v-else-if="row.type === 'jobItems'" class="gl-min-w-0">
              <template v-if="row.jobItems.length">
                <gl-intersperse>
                  <gl-link
                    v-for="jobItem in row.jobItems"
                    :key="jobItem.iid"
                    :href="jobItem.webPath"
                    class="gl-text-inherit gl-no-underline hover:gl-text-link hover:gl-underline"
                    >{{ jobItem.iid }}</gl-link
                  >
                </gl-intersperse>
              </template>
              <template v-else>{{ __('None') }}</template>
              <p class="gl-mb-0 gl-mt-1 gl-text-sm gl-text-subtle">
                {{ s__('DuoAgentsPlatform|Raw runner output') }}
              </p>
            </span>
            <span v-else class="gl-inline-flex gl-items-center gl-gap-2">
              <gl-icon v-if="row.icon" :name="row.icon" variant="subtle" :size="14" />
              <gl-link
                v-if="row.link"
                :href="row.link"
                class="gl-text-inherit gl-no-underline hover:gl-text-link hover:gl-underline"
                >{{ row.text }}</gl-link
              >
              <template v-else>{{ row.text }}</template>
            </span>
          </dd>
        </div>
      </dl>
    </template>
  </gl-attribute-list>
</template>
