<script>
import { GlFormGroup, GlFormInput, GlSprintf, GlButton } from '@gitlab/ui';
import { v4 } from 'uuid';
import { s__ } from '~/locale';
import HelpPageLink from '~/vue_shared/components/help_page_link/help_page_link.vue';

const genNewInputField = () => ({
  key: '',
  value: '',
  seed: v4(),
});

export default {
  components: {
    GlFormInput,
    GlFormGroup,
    GlButton,
    GlSprintf,
    HelpPageLink,
  },
  data() {
    return {
      ciComponents: [],
    };
  },
  watch: {
    ciComponents: {
      handler() {
        this.$emit('update', this.ciComponents);
      },
      deep: true,
    },
  },
  methods: {
    deleteInputItem(inputs, idx) {
      inputs.splice(idx, 1);
    },
    addNewInput(inputs) {
      inputs.push(genNewInputField());
    },
    addNewComponent() {
      this.ciComponents.push({
        component: '',
        inputs: [genNewInputField()],
        seed: v4(),
      });
    },
    deleteComponent(idx) {
      this.ciComponents.splice(idx, 1);
    },
  },

  i18n: {
    help: s__(
      'JH|CiComponents|For correctly include component references, you may refer to the CI component documentation. %{linkStart}Learn more%{linkEnd}',
    ),
    title: s__('JH|CiComponents|CI component'),
    componentName: s__('JH|CiComponents|Component reference'),
    addNewComponent: s__('JH|CiComponents|Add component'),
    inputs: s__('JH|CiComponents|Inputs'),
    addNewInputField: s__('JH|CiComponents|Add field'),
  },
};
</script>

<template>
  <div>
    <p class="gl-mb-5">
      <gl-sprintf :message="$options.i18n.help">
        <template #link="{ content }">
          <help-page-link href="/ci/components/index.html" target="__blank">{{
            content
          }}</help-page-link>
        </template>
      </gl-sprintf>
    </p>

    <div
      v-for="(ciComponent, idx) in ciComponents"
      :key="ciComponent.seed"
      data-testid="ci-component"
      class="gl-relative gl-mb-5 gl-bg-gray-10 gl-p-5"
    >
      <gl-button
        class="gl-absolute gl-right-3 gl-top-3"
        category="tertiary"
        data-testid="ci-component-delete-component-btn"
        icon="remove"
        @click="deleteComponent(idx)"
      />
      <gl-form-group :label="$options.i18n.componentName" required>
        <gl-form-input v-model="ciComponent.component" />
      </gl-form-group>
      <p class="gl-font-bold">{{ $options.i18n.inputs }}</p>
      <div
        v-for="(input, index) in ciComponent.inputs"
        :key="input.seed"
        data-testid="ci-component-input"
        class="gl-mb-3 gl-flex gl-items-center gl-justify-between"
      >
        <div class="gl-mr-3 gl-flex gl-grow gl-basis-0 gl-gap-3">
          <gl-form-input v-model="input.key" :placeholder="__('Key')" />
          <gl-form-input v-model="input.value" :placeholder="__('Value')" />
        </div>

        <gl-button
          v-if="ciComponent.inputs.length > 1"
          category="tertiary"
          data-testid="ci-component-delete-input-btn"
          icon="remove"
          @click="deleteInputItem(ciComponent.inputs, index)"
        />
      </div>
      <gl-button data-testid="add-ci-component-input-btn" @click="addNewInput(ciComponent.inputs)">
        {{ $options.i18n.addNewInputField }}
      </gl-button>
    </div>
    <gl-button
      category="secondary"
      data-testid="add-ci-component-btn"
      variant="confirm"
      @click="addNewComponent"
    >
      {{ $options.i18n.addNewComponent }}
    </gl-button>
  </div>
</template>
