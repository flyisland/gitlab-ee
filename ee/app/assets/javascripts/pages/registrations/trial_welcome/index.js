import { initSimpleApp } from '~/helpers/init_simple_app_helper';
import apolloProvider from 'ee/subscriptions/graphql/graphql';
import CreateTrialWelcomeForm from 'ee/trials/components/create_trial_welcome_form.vue';
import TrialWelcomeForm from 'ee/registrations/components/trial_welcome_form.vue';

const el = document.querySelector('#js-create-trial-welcome-form');

if (el) {
  const { trialUnification } = JSON.parse(el.dataset.viewModel || '{}');
  const component = trialUnification ? TrialWelcomeForm : CreateTrialWelcomeForm;

  initSimpleApp('#js-create-trial-welcome-form', component, {
    withApolloProvider: apolloProvider,
  });
}
