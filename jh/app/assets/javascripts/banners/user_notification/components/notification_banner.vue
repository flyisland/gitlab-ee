<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  name: 'NotificationBannerApp',
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    LocalStorageSync,
  },
  mixins: [timeagoMixin],
  props: {
    daysLeft: {
      type: [Number, String],
      required: true,
    },
    customerDotLink: {
      type: String,
      required: true,
    },
    updatedAt: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      notificationDismissed: false,
    };
  },
  computed: {
    inSevenDays() {
      return this.daysLeft <= 7;
    },
    dismissible() {
      return !this.inSevenDays;
    },
    showAlert() {
      if (this.inSevenDays) {
        return true;
      }

      return !this.notificationDismissed;
    },
    sevenDaysDescription() {
      return n__(
        'JH|Account|Your free usage at jihulab.com will end in 1 day. Please consider to %{subscribeLinkStart}upgrade to a paid plan%{subscribeLinkEnd} if you need to continue to use your account after that.',
        'JH|Account|Your free usage at jihulab.com will end in %{days} days. Please consider to %{subscribeLinkStart}upgrade to a paid plan%{subscribeLinkEnd} if you need to continue to use your account after that.',
        this.daysLeft,
      );
    },
    thirtyDaysDescription() {
      return n__(
        'JH|Account|Your free usage at jihulab.com will end in 1 day. Please consider to %{subscribeLinkStart}upgrade to a paid plan%{subscribeLinkEnd} before that date to avoid account being blocked.',
        'JH|Account|Your free usage at jihulab.com will end in %{days} days. Please consider to %{subscribeLinkStart}upgrade to a paid plan%{subscribeLinkEnd} before that date to avoid account being blocked.',
        this.daysLeft,
      );
    },
    description() {
      return this.inSevenDays ? this.sevenDaysDescription : this.thirtyDaysDescription;
    },
  },
  methods: {
    updateStorageKey(value) {
      this.notificationDismissed = Boolean(value);
    },
  },
  storageKey: 'user-account-expiry-notification',
  i18n: {
    title: s__('JH|Account|Account deletion warning'),
    updatedAt: s__('JH|Account|Updated at %{updatedAt}'),
  },
};
</script>
<template>
  <local-storage-sync
    :storage-key="$options.storageKey"
    :value="notificationDismissed"
    @input="updateStorageKey"
  >
    <gl-alert
      v-if="showAlert"
      variant="warning"
      :title="$options.i18n.title"
      :dismissible="dismissible"
      @dismiss="updateStorageKey(true)"
    >
      <gl-sprintf :message="description">
        <template #days>
          <strong>
            {{ daysLeft }}
          </strong>
        </template>
        <template #subscribeLink="{ content }">
          <gl-link :href="customerDotLink" target="_blank">
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>

      <p v-if="updatedAt" class="gl-mb-0 gl-pt-5 gl-text-sm gl-text-secondary">
        <gl-sprintf :message="$options.i18n.updatedAt">
          <template #updatedAt>
            {{ tooltipTitle(updatedAt) }}
          </template>
        </gl-sprintf>
      </p>
    </gl-alert>
  </local-storage-sync>
</template>
