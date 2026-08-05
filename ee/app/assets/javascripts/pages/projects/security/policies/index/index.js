import { NAMESPACE_TYPES } from 'ee/security_orchestration/constants';
import initSecurityPoliciesList from 'ee/security_orchestration/security_policies_list';
import initSecurityPoliciesV2 from 'ee/security_policies';

const experimentalPoliciesV2 = document.getElementById('js-security-policies-v2');

if (experimentalPoliciesV2) {
  initSecurityPoliciesV2(experimentalPoliciesV2, NAMESPACE_TYPES.PROJECT);
} else {
  initSecurityPoliciesList(
    document.getElementById('js-security-policies-list'),
    NAMESPACE_TYPES.PROJECT,
  );
}
