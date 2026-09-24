<script>
import { GlDrawer, GlButton } from '@gitlab/ui';
import { stringify, parse } from 'yaml';
import { DRAWER_Z_INDEX } from '~/lib/utils/constants';
import { getContentWrapperHeight } from '~/lib/utils/dom_utils';
import eventHub, { SCROLL_EDITOR_TO_BOTTOM } from '~/ci/pipeline_editor/event_hub';
import { EDITOR_APP_DRAWER_NONE } from '~/ci/pipeline_editor/constants';

import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import CiComponent from './ci_component.vue';

const mapComponent = ({ component, inputs }) => {
  return {
    component,
    inputs: inputs.map(({ key, value }) => ({ [key]: value })),
  };
};

export default {
  components: {
    GlDrawer,
    GlButton,
    CiComponent,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    isVisible: {
      type: Boolean,
      required: false,
      default: false,
    },
    zIndex: {
      type: Number,
      required: false,
      default: DRAWER_Z_INDEX,
    },
    ciFileContent: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      components: [],
    };
  },
  computed: {
    getDrawerHeaderHeight() {
      return getContentWrapperHeight();
    },
  },
  methods: {
    closeDrawer() {
      this.clearComponents();
      this.$emit('switch-drawer', EDITOR_APP_DRAWER_NONE);
    },
    addCiConfig() {
      if (!this.validateJob()) {
        return;
      }

      const parsedDocument = parse(this.ciFileContent, { version: '1.1' });

      const { include } = parsedDocument;
      const components = this.components.map(mapComponent);
      let newYamlString = this.ciFileContent;

      if (include && include.length > 0) {
        include.push(...components);
        newYamlString = stringify(parsedDocument);
      } else {
        newYamlString = [stringify({ include: components }), this.ciFileContent].join('\n');
      }
      this.$emit('updateCiConfig', newYamlString);
      eventHub.$emit(SCROLL_EDITOR_TO_BOTTOM);

      this.closeDrawer();
    },
    updateComponents(components) {
      this.components = components;
    },
    clearComponents() {
      this.components = [];
    },
    validateJob() {
      return this.components.every(({ component, inputs }) => {
        return (
          Boolean(component) && inputs.every(({ key, value }) => Boolean(key) && Boolean(value))
        );
      });
    },
  },
};
</script>
<template>
  <gl-drawer
    class="job-assistant-drawer"
    :header-height="getDrawerHeaderHeight"
    :open="isVisible"
    :z-index="zIndex"
    @close="closeDrawer"
  >
    <template #title>
      <h2 class="gl-m-0 gl-text-lg">{{ s__('JH|CiComponents|Add CI components') }}</h2>
    </template>
    <ci-component @update="updateComponents" />
    <template #footer>
      <div class="gl-flex gl-justify-end">
        <gl-button
          category="primary"
          class="gl-mr-3"
          data-testid="ci-component-cancel-button"
          @click="closeDrawer"
          >{{ __('Cancel') }}
        </gl-button>
        <gl-button
          category="primary"
          variant="confirm"
          data-testid="ci-component-confirm-button"
          @click="addCiConfig"
          >{{ __('Add') }}
        </gl-button>
      </div>
    </template>
  </gl-drawer>
</template>
