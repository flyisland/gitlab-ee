import { join } from 'node:path';
import { HttpResponse } from 'msw';
import { createFixturePaginator, loadFixturesMap } from 'ee_jest/integration/core/fixture_utils';
import { getActiveVariant } from 'ee_jest/integration/core/fixture_variant_schema';
import './fixture_variants/pipeline_findings';

const FIXTURES_PATH = join('tmp/tests/frontend/fixtures-ee/graphql/ci/pipelines/integration/');
const fixtures = loadFixturesMap(FIXTURES_PATH);

const paginateFindings = createFixturePaginator({ lookupKey: 'securityReportFindings' });

const STATIC_OPERATION_HANDLERS = Object.fromEntries(
  Object.entries(fixtures).map(([operationName, fixture]) => [
    operationName,
    () => getActiveVariant(operationName) ?? fixture,
  ]),
);

const OPERATION_HANDLERS = {
  ...STATIC_OPERATION_HANDLERS,
  pipelineFindings: ({ variables }) =>
    paginateFindings(getActiveVariant('pipelineFindings') ?? fixtures.pipelineFindings, variables),
};

export function handlePipelineSecurityOperation({ operationName, variables }) {
  const handler = OPERATION_HANDLERS[operationName];

  if (!handler) {
    return null;
  }

  return HttpResponse.json(handler({ variables }));
}

export const pipelineSecurityRestEndpoints = [];
