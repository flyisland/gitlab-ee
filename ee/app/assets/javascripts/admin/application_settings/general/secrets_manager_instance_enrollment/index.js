import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import SecretsManagerInstanceEnrollmentToggle from './components/secrets_manager_instance_enrollment_toggle.vue';

Vue.use(GlToast);
Vue.use(VueApollo);

export const initSecretsManagerInstanceEnrollment = () => {
  const el = document.getElementById('js-secrets-manager-instance-enrollment');

  if (!el) return false;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el,
    name: 'SecretsManagerInstanceEnrollmentRoot',
    apolloProvider,
    render(createElement) {
      return createElement(SecretsManagerInstanceEnrollmentToggle);
    },
  });
};
