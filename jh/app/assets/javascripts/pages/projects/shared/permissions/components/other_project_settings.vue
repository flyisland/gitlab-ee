<script>
import { GlFormCheckbox, GlLink, GlSprintf } from '@gitlab/ui';
import {
  I18N_NEW_PROJECT_TERMS_DECLARATION,
  I18N_NEW_PROJECT_TERMS_ONE,
  I18N_NEW_PROJECT_TERMS_TWO,
  PUBLIC_VISIBILITY_LEVEL,
} from 'jh/projects/new/constants';
import { PROMO_URL } from 'jh/lib/utils/url_utility';

export default {
  components: {
    GlLink,
    GlSprintf,
    GlFormCheckbox,
  },
  data() {
    return {
      initedVisibilityLevel: this.$parent.visibilityLevel,
      agreeJihuTerms: false,
      agreeIntellectualProperty: false,
    };
  },
  computed: {
    visibilityLevel() {
      return this.$parent.visibilityLevel;
    },
    showTerms() {
      return (
        this.visibilityLevel === PUBLIC_VISIBILITY_LEVEL &&
        this.initedVisibilityLevel !== PUBLIC_VISIBILITY_LEVEL &&
        window.gon.dot_com
      );
    },
  },
  i18n: {
    I18N_NEW_PROJECT_TERMS_DECLARATION,
    I18N_NEW_PROJECT_TERMS_ONE,
    I18N_NEW_PROJECT_TERMS_TWO,
  },
  urls: {
    termsLink: `${PROMO_URL}/terms/`,
  },
};
</script>

<template>
  <div v-if="showTerms" data-testid="project-setting-terms">
    <label class="label-bold" for="project_project_configuration">{{
      $options.i18n.I18N_NEW_PROJECT_TERMS_DECLARATION
    }}</label>
    <div class="gl-mb-5">
      <input
        :value="agreeJihuTerms"
        type="hidden"
        name="project[project_setting_attributes][agree_jihu_terms]"
      />
      <gl-form-checkbox
        v-model="agreeJihuTerms"
        name="project[project_setting_attributes][agree_jihu_terms]"
        :required="true"
      >
        <gl-sprintf :message="$options.i18n.I18N_NEW_PROJECT_TERMS_ONE">
          <template #link="{ content }">
            <gl-link :href="$options.urls.termsLink" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </gl-form-checkbox>
    </div>
    <div class="gl-mb-5">
      <input
        :value="agreeIntellectualProperty"
        type="hidden"
        name="project[project_setting_attributes][agree_intellectual_property]"
      />
      <gl-form-checkbox
        v-model="agreeIntellectualProperty"
        name="project[project_setting_attributes][agree_intellectual_property]"
        :required="true"
      >
        {{ $options.i18n.I18N_NEW_PROJECT_TERMS_TWO }}
      </gl-form-checkbox>
    </div>
  </div>
</template>
