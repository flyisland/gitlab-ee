<script>
export default {
  props: {
    id: {
      type: [Number, String],
      required: true,
    },
    projectFullPath: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-items-center gl-justify-center gl-py-7 gl-text-base gl-font-bold">
    {{
      s__(
        'JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed. To appeal, please click',
      )
    }}<span
      class="js-appeal-modal gl-ml-2 gl-cursor-pointer gl-text-blue-500"
      :data-id="id"
      :data-project-full-path="projectFullPath"
      :data-path="path"
      >{{ s__('JH|ContentValidation|here') }}</span
    >
  </div>
</template>
