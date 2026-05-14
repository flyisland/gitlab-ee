export const autoDismissVulnerabilityPoliciesEnabled = () => {
  return window.gon?.features?.policyAutoDismissedEsFilter;
};
