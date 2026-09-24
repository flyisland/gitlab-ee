import Vue from 'vue';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';

const I18N_ILLEGAL_CHARACTERS_TIPS_WITH_APPEAL_EMAIL = s__(
  "JH|ContentValidation|Your content couldn't be submitted because it violated the rules. If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. We will process your appeal within 24 hours (working days) and send the result to your registered email address, please pay attention to it. Thank you for your understanding and support.",
);

const handleContentValidationError = (originHandler, component, err) => {
  if (err.response?.data?.content_invalid) {
    createAlert({
      message: I18N_ILLEGAL_CHARACTERS_TIPS_WITH_APPEAL_EMAIL,
      parent: component ? component.$el : document,
    });
  } else {
    originHandler.call(component, err);
  }
};

const methodOverrides = {
  CommentForm: ({ handleSaveError }) => ({
    handleSaveError({ data, status }) {
      if (data?.content_invalid) {
        this.errors = [I18N_ILLEGAL_CHARACTERS_TIPS_WITH_APPEAL_EMAIL];
      } else {
        handleSaveError.call(this, { data, status });
      }
    },
  }),
  NoteableNote: ({ handleUpdateError }) => ({
    handleUpdateError(err) {
      handleContentValidationError(handleUpdateError, this, err);
    },
  }),
  NoteableDiscussion: ({ handleSaveError }) => ({
    handleSaveError(err) {
      handleContentValidationError(handleSaveError, this, err);
    },
  }),
};

Vue.mixin({
  created() {
    const createMethodOverrides = methodOverrides[this.$options.name];

    if (createMethodOverrides) {
      // Override bound instance methods after option initialization; Vue 3 compat exposes
      // `this.$options` as a shallow copy. This also avoids static notes imports.
      for (const [name, method] of Object.entries(createMethodOverrides(this))) {
        this[name] = method.bind(this);
      }
    }
  },
});
