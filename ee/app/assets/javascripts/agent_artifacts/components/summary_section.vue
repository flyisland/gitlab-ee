<script>
import { s__ } from '~/locale';
import { formatDate } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { LONG_DATE_FORMAT_WITH_TZ } from '~/vue_shared/constants';

const EM_DASH = '—';

export default {
  name: 'SummarySection',
  components: {
    CrudComponent,
  },
  props: {
    event: {
      type: Object,
      required: true,
    },
    targetType: {
      type: String,
      required: false,
      default: '',
    },
    targetDetails: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    leftColumn() {
      const { event } = this;

      return [
        {
          testid: 'summary-row-author-id',
          label: this.$options.i18n.authorId,
          value: event.author?.id ? getIdFromGraphQLId(event.author.id) : null,
        },
        {
          testid: 'summary-row-author-name',
          label: this.$options.i18n.authorName,
          value: event.author?.name,
        },
        {
          testid: 'summary-row-target-type',
          label: this.$options.i18n.targetType,
          value: this.targetType,
        },
        {
          testid: 'summary-row-target-details',
          label: this.$options.i18n.targetDetails,
          value: this.targetDetails,
        },
      ];
    },
    rightColumn() {
      const { event } = this;

      return [
        {
          testid: 'summary-row-event-type',
          label: this.$options.i18n.eventType,
          value: event.eventName,
        },
        {
          testid: 'summary-row-ip-address',
          label: this.$options.i18n.ipAddress,
          value: event.ipAddress,
        },
        {
          testid: 'summary-row-timestamp',
          label: this.$options.i18n.timestamp,
          value: event.createdAt ? formatDate(event.createdAt, LONG_DATE_FORMAT_WITH_TZ) : null,
        },
      ];
    },
    columns() {
      return [this.leftColumn, this.rightColumn];
    },
  },
  methods: {
    displayValue(value) {
      return value || EM_DASH;
    },
  },
  i18n: {
    title: s__('AgentArtifacts|Summary'),
    authorId: s__('AgentArtifacts|Author ID'),
    authorName: s__('AgentArtifacts|Author name'),
    targetType: s__('AgentArtifacts|Target type'),
    targetDetails: s__('AgentArtifacts|Target details'),
    eventType: s__('AgentArtifacts|Event type'),
    ipAddress: s__('AgentArtifacts|IP address'),
    timestamp: s__('AgentArtifacts|Timestamp'),
  },
};
</script>

<template>
  <crud-component :title="$options.i18n.title" is-collapsible>
    <div class="gl-flex gl-flex-col @sm/panel:gl-flex-row @sm/panel:gl-gap-x-7">
      <ul
        v-for="(column, index) in columns"
        :key="index"
        class="gl-m-0 gl-list-disc gl-pl-5 @sm/panel:gl-w-1/2"
      >
        <li
          v-for="row in column"
          :key="row.testid"
          :data-testid="row.testid"
          class="gl-break-words gl-py-1"
        >
          <span class="gl-font-bold">{{ row.label }}</span>
          - <span>{{ displayValue(row.value) }}</span>
        </li>
      </ul>
    </div>
  </crud-component>
</template>
