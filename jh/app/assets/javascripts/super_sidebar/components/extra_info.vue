<script>
import { GlButton, GlDisclosureDropdown } from '@gitlab/ui';
import WeChatIcon from '@jihu-fe/svgs/dist/illustrations/jh/logos/wechat.svg?raw';
import QrCode from 'jh_images/illustrations/wechat-com.svg?url';
import SafeHtmlDirective from '~/vue_shared/directives/safe_html';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import { languageCode } from '~/locale';

const DROPDOWN_X_OFFSET = -4;
const STORAGE_KEY = 'jh_super_sidebar_qr_code_clicked';
const userLanguage = languageCode();

export default {
  name: 'SuperSidebarQrCode',
  components: {
    GlButton,
    GlDisclosureDropdown,
    LocalStorageSync,
  },
  directives: {
    SafeHtml: SafeHtmlDirective,
  },
  data() {
    return {
      shouldHighlight: true,
    };
  },
  computed: {
    isSelfManage() {
      return !window.gon.dot_com;
    },
    shouldShow() {
      return this.isSelfManage && !gon.has_active_license;
    },
    showText() {
      // Since the text is too long for other languages other than Chinese
      // It will look better to hide the text
      return userLanguage === 'zh-CN';
    },
  },
  methods: {
    onLocalStorageSync(val) {
      this.shouldHighlight = val;
    },
  },
  dropdownOffset: { crossAxis: DROPDOWN_X_OFFSET },
  storageKey: STORAGE_KEY,
  svg: {
    WeChatIcon,
    QrCode,
  },
};
</script>

<template>
  <local-storage-sync
    v-if="shouldShow"
    :value="shouldHighlight"
    :storage-key="$options.storageKey"
    data-testid="super-sidebar-qr-code"
    @input="onLocalStorageSync"
  >
    <gl-disclosure-dropdown :dropdown-offset="$options.dropdownOffset">
      <template #toggle>
        <!-- eslint-disable @gitlab/vue-require-i18n-attribute-strings -->
        <gl-button
          aria-label="Wexin icon"
          category="tertiary"
          class="btn-with-notification"
          @click="shouldHighlight = false"
        >
          <!-- eslint-enable @gitlab/vue-require-i18n-attribute-strings -->
          <span
            v-safe-html="$options.svg.WeChatIcon"
            class="gl-inline-flex gl-items-center gl-justify-center gl-align-middle"
          >
          </span>
          <span
            v-if="shouldHighlight"
            data-testid="notification-dot"
            class="notification-dot-info"
          ></span>
          <template v-if="showText">
            {{ __('Support') }}
          </template>
        </gl-button>
      </template>

      <div class="gl-flex gl-flex-col gl-items-center gl-p-5">
        <img width="168" height="168" class="gl-pb-4" :src="$options.svg.QrCode" />
        <div class="gl-flex gl-flex-col">
          <p class="gl-mb-0 gl-text-center gl-font-bold">
            {{ s__('JH|Support|Scan the QR code to join our WeChat group') }}
          </p>
          <p class="gl-mb-0 gl-text-center gl-leading-24">
            {{ s__('JH|Support|1. Access enterprise-level DevOps solutions support') }}
          </p>
          <p class="gl-mb-0 gl-text-center gl-leading-24">
            {{
              s__('JH|Support|2. Free or Discount JiHu Gitlab official training and certification')
            }}
          </p>
        </div>
      </div>
    </gl-disclosure-dropdown>
  </local-storage-sync>
</template>
