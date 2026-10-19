import { join } from 'node:path';
import { HttpResponse } from 'msw';
import { loadFixturesMap } from 'ee_jest/integration/core/fixture_utils';
import { getActiveVariant } from 'ee_jest/integration/core/fixture_variant_schema';
import policySchema from '../../../../app/validators/json_schemas/security_orchestration_policy.json';
import projectSecurityPoliciesVariants from './fixture_variants/project_security_policies';
import groupSecurityPoliciesVariants from './fixture_variants/group_security_policies';
import updatePolicyVariants from './fixture_variants/update_policy';
import getFileVariants from './fixture_variants/get_file';

const FIXTURES_PATH = join('tmp/tests/frontend/fixtures-ee/graphql/security_policies/integration/');
const fixtures = loadFixturesMap(FIXTURES_PATH);

const STATIC_OPERATION_HANDLERS = Object.fromEntries(
  Object.entries(fixtures).map(([operationName, fixture]) => [operationName, () => fixture]),
);

const VARIANT_OPERATION_HANDLERS = {
  projectSecurityPolicies: () =>
    getActiveVariant('projectSecurityPolicies') ?? projectSecurityPoliciesVariants.BASE,
  groupSecurityPolicies: () =>
    getActiveVariant('groupSecurityPolicies') ?? groupSecurityPoliciesVariants.BASE,
  updatePolicy: () => getActiveVariant('updatePolicy') ?? updatePolicyVariants.BASE,
  getFile: () => getActiveVariant('getFile') ?? getFileVariants.BASE,
};

const OPERATION_HANDLERS = {
  ...STATIC_OPERATION_HANDLERS,
  ...VARIANT_OPERATION_HANDLERS,
  // The DAST profile queries name their operations in PascalCase, which the camelCased
  // keys `loadFixturesMap` derives from the fixture filenames cannot reach.
  DastSiteProfiles: () => fixtures.dastSiteProfiles,
  DastScannerProfiles: () => fixtures.dastScannerProfiles,
};

export function handleSecurityPolicyOperation({ operationName }) {
  const handler = OPERATION_HANDLERS[operationName];

  if (!handler) {
    return null;
  }

  return HttpResponse.json(handler());
}

// YAML mode asks for the policy schema to drive validation and autocomplete.
// `getSinglePolicySchema` swallows a failed fetch, so without this the editor silently
// loses both rather than failing a spec. Served from the file the controller renders, so
// a spec asserting on the schema cannot drift from what the backend actually sends.
export const securityPolicyRestEndpoints = [
  {
    method: 'get',
    path: /\/-\/security\/policies\/schema$/,
    name: 'securityPolicySchema',
    response: policySchema,
  },
];
