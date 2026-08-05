import { shouldQrtlyReconciliationMount } from 'ee/billings/qrtly_reconciliation';
import initSubscriptions from 'ee/billings/subscriptions';
import { initSimpleApp } from '~/helpers/init_simple_app_helper';
import FreeTrialBillingWithDapMonthlyCommitApp from 'ee/groups/billing/components/app_with_dap_monthly_commit.vue';
import FreeTrialBillingWithUpgradeSubscriptionApp from 'ee/groups/billing/components/app_with_upgrade_subscription.vue';
import TargetedMessageBanner from 'ee/targeted_message_banner/components/index.vue';

initSimpleApp('#js-targeted-message-banner', TargetedMessageBanner, { withApolloProvider: true });
initSubscriptions();
shouldQrtlyReconciliationMount();
initSimpleApp(
  '#js-free-trial-plan-billing-with-dap-monthly-commit',
  FreeTrialBillingWithDapMonthlyCommitApp,
  { additionalProvide: { glFeatures: window.gon?.features || {} } },
);
initSimpleApp(
  '#js-free-trial-plan-billing-with-upgrade-subscription',
  FreeTrialBillingWithUpgradeSubscriptionApp,
  { additionalProvide: { glFeatures: window.gon?.features || {} } },
);
