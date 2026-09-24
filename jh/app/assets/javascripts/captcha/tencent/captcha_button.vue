<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import SafeHtml from '~/vue_shared/directives/safe_html';
import { initTencentCaptchaScript } from 'jh/captcha/tencent/init_script';
import defaultTanuki from 'jh_images/captcha/tanuki-verify.svg?raw';
import verifiedTanuki from 'jh_images/captcha/tanuki-verified.svg?raw';
import { LOADING, READY, RESOLVING, DONE, i18n } from 'jh/captcha/tencent/constants';

export default {
  i18n,
  statusMap: {
    READY,
    RESOLVING,
    DONE,
  },
  svgMap: {
    [READY]: defaultTanuki,
    [DONE]: verifiedTanuki,
  },
  components: {
    GlLoadingIcon,
  },
  directives: {
    SafeHtml,
  },
  props: {
    captchaSiteKey: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      captchaResponse: '',
      status: LOADING,
      captcha: null,
    };
  },
  computed: {
    buttonText() {
      return this.$options.i18n[this.status];
    },
    showCaptcha() {
      return [READY, RESOLVING, DONE].includes(this.status);
    },
  },
  mounted() {
    initTencentCaptchaScript()
      .then((TencentCaptcha) => {
        this.captcha = TencentCaptcha;
        this.status = READY;

        if (!this.$el.closest('.hidden')) {
          this.startResolving();
        }
      })
      .catch((e) => {
        createAlert({
          message: s__('JH|Captcha|There was an error with the captcha. Please try again.'),
        });
        this.$emit('loadError', e);
      });
  },
  methods: {
    emitReceivedCaptchaResponse(captchaResponse) {
      this.$emit('receivedCaptchaResponse', captchaResponse);
    },
    startResolving() {
      if (this.status !== this.$options.statusMap.READY) {
        return;
      }

      this.status = this.$options.statusMap.RESOLVING;
      const TencentCaptcha = this.captcha;
      const captcha = new TencentCaptcha(
        this.captchaSiteKey,
        (res) => {
          if (res.ret === 0) {
            /* captcha succeed */
            const captchaResponse = btoa(
              JSON.stringify({
                rand_str: res.randstr,
                ticket: res.ticket,
              }),
            );
            this.status = this.$options.statusMap.DONE;
            this.captchaResponse = captchaResponse;
            this.emitReceivedCaptchaResponse(captchaResponse);
          } else if (res.ret === 2) {
            /* captcha canceled */
            this.status = this.$options.statusMap.READY;
          }
        },
        { loading: false },
      );
      captcha.show();
    },
  },
};
</script>
<template>
  <div
    class="tencent-captcha gl-hidden gl-items-center gl-rounded-base gl-bg-white gl-font-regular gl-text-base gl-leading-normal gl-text-gray-900 !gl-shadow-inner-1-gray-100 hover:gl-bg-gray-50"
    :class="{ 'gl-cursor-pointer': status === $options.statusMap.READY }"
    @click="startResolving"
  >
    <input type="hidden" name="jh_captcha_response" :value="captchaResponse" />
    <transition name="fade" mode="out-in">
      <div v-if="showCaptcha" :key="status">
        <div class="gl-flex gl-items-center">
          <div
            v-if="status === $options.statusMap.RESOLVING"
            class="gl-ml-6 gl-mr-4 gl-flex gl-w-6 gl-items-center"
          >
            <gl-loading-icon />
          </div>
          <div
            v-else
            v-safe-html="$options.svgMap[status]"
            class="gl-ml-6 gl-mr-4 gl-flex gl-w-6 gl-items-center"
          ></div>
          <span>{{ buttonText }}</span>
        </div>
      </div>
    </transition>
  </div>
</template>
<style scoped>
.tencent-captcha {
  width: 300px;
  height: 74px;
}
</style>
