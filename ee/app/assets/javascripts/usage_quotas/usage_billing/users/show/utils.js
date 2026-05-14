import { s__ } from '~/locale';
import { logError } from '~/lib/logger';
import { captureException } from '~/sentry/sentry_browser_wrapper';

// This object maps flow type IDs to localized titles
//
// It should stay synchronized with the flow types defined in the Customers portal codebase:
// https://gitlab.com/gitlab-org/customers-gitlab-com/-/blob/main/app/models/billing/usage/flow_type_registry.rb
//
// Note: When new flow types are added to the API but not yet included here,
// we will fall back to using the English title from the API response.
const LOCALIZED_FLOW_TYPES = {
  ai_catalog_based_agent_or_flow: s__('UsageBillingFlowType|AI Catalog based Agent or Flow'),
  other_ai_usage: s__('UsageBillingFlowType|Other AI Usage'),
  foundational_agents: s__('UsageBillingFlowType|Foundational Agents'),
  agentic_chat: s__('UsageBillingFlowType|Agentic Chat'),
  code_review_flow: s__('UsageBillingFlowType|Code Review Flow'),
  code_suggestions: s__('UsageBillingFlowType|Code Suggestions'),
  convert_to_gitlab_ci_cd_flow: s__('UsageBillingFlowType|Convert to GitLab CI/CD Flow'),
  dap_feature_legacy: s__('UsageBillingFlowType|DAP Feature (Legacy)'),
  developer_flow: s__('UsageBillingFlowType|Developer Flow'),
  fix_pipeline_flow: s__('UsageBillingFlowType|Fix Pipeline Flow'),
  issue_to_merge_request_flow: s__('UsageBillingFlowType|Issue to Merge Request Flow'),
  sast_vulnerability_resolution_flow: s__(
    'UsageBillingFlowType|SAST Vulnerability Resolution Flow',
  ),
  sast_fp_detection_flow: s__('UsageBillingFlowType|SAST FP Detection Flow'),
  software_development_flow: s__('UsageBillingFlowType|Software Development Flow'),
};

/**
 * Transforms API response into a format suitable for the UI.
 *
 * @param {{id:string, title:string}[]} rawFlowTypes
 */
export function processFlowTypes(rawFlowTypes) {
  const idsMissingLocalisation = [];
  const localisedFlowTypes = rawFlowTypes.map((rawFlowType) => {
    const value = rawFlowType.id;
    // Find the localized title or fall back to the English title from the API
    let text = LOCALIZED_FLOW_TYPES[rawFlowType.id];
    if (!text) {
      idsMissingLocalisation.push(rawFlowType.id);
      text = rawFlowType.title;
    }
    return { value, text };
  });

  if (idsMissingLocalisation.length) {
    const error = new Error(`Missing localized flow type: ${idsMissingLocalisation.join(', ')}`);
    logError(error);
    captureException(error);
  }
  return localisedFlowTypes;
}
