import { autoDismissVulnerabilityPoliciesEnabled } from 'ee/security_dashboard/utils';

describe('autoDismissVulnerabilityPoliciesEnabled', () => {
  it.each`
    policyAutoDismissedEsFilter | expected
    ${false}                    | ${false}
    ${true}                     | ${true}
  `(
    'returns correct output when policyAutoDismissedEsFilter=$policyAutoDismissedEsFilter',
    ({ policyAutoDismissedEsFilter, expected }) => {
      window.gon.features = { policyAutoDismissedEsFilter };
      expect(autoDismissVulnerabilityPoliciesEnabled()).toBe(expected);
    },
  );
});
