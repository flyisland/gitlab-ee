import { initGitlabCreditsDashboard } from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index';
import { initUsageBillingDashboard } from 'ee/usage_quotas/usage_billing/index';

const el = document.getElementById('js-group-usage-billing-dashboard');

if (gon?.features?.walletAgnosticCreditsDashboard) {
  initGitlabCreditsDashboard(el);
} else {
  initUsageBillingDashboard(el);
}
