import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import { injectVueAppBreadcrumbs } from '~/lib/utils/breadcrumbs';
import { SECRETS_MANAGER_CONTEXT_CONFIG } from './context_config';
import createRouter from './router';
import SecretsApp from './components/secrets_app.vue';
import SecretsBreadcrumbs from './components/secrets_breadcrumbs.vue';
import { ENTITY_GROUP, ENTITY_PROJECT } from './constants';

Vue.use(VueApollo);
Vue.use(GlToast);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

const paidExperienceFF = gon.features?.secretsManagerPaidExperience;
const isSaas = gon.dot_com;

const initSecretsApp = (el, provide) => {
  const { basePath, enrollmentSettingsPath } = el.dataset;

  const isEligibleForTrial = paidExperienceFF && provide.trialStatus?.isEligible;
  const extendedProvided = {
    ...provide,
    enrollmentSettingsPath,
    isEligibleForTrial,
    isSaas: parseBoolean(isSaas),
  };

  const router = createRouter(basePath, isEligibleForTrial);

  if (window.location.href.includes(basePath)) {
    injectVueAppBreadcrumbs(router, SecretsBreadcrumbs);
  }

  return new Vue({
    el,
    router,
    name: 'SecretsRoot',
    provide: extendedProvided,
    apolloProvider,
    render(createElement) {
      return createElement(SecretsApp);
    },
  });
};

export const initGroupSecretsApp = () => {
  const el = document.querySelector('#js-group-secrets-manager');

  if (!el) {
    return false;
  }

  const { groupPath } = el.dataset;

  return initSecretsApp(el, {
    contextConfig: SECRETS_MANAGER_CONTEXT_CONFIG[ENTITY_GROUP],
    fullPath: groupPath,
    // TODO: hard-coded for now while value is not yet available from backend
    // See: https://gitlab.com/groups/gitlab-org/-/work_items/21755#note_3423015919
    trialStatus: {
      isEligible: false,
    },
  });
};

export const initProjectSecretsApp = () => {
  const el = document.querySelector('#js-project-secrets-manager');

  if (!el) {
    return false;
  }

  const { projectPath } = el.dataset;

  return initSecretsApp(el, {
    contextConfig: SECRETS_MANAGER_CONTEXT_CONFIG[ENTITY_PROJECT],
    fullPath: projectPath,
    // TODO: hard-coded for now while value is not yet available from backend
    // See: https://gitlab.com/groups/gitlab-org/-/work_items/21755#note_3423015919
    trialStatus: {
      isEligible: false,
    },
  });
};
