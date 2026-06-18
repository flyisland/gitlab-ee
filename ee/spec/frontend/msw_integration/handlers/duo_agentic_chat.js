import { join } from 'node:path';
import { parseGid } from '~/graphql_shared/utils';
import { loadFixturesMap } from 'jest/msw_integration/fixture_utils';

const FIXTURES_PATH = join('tmp/tests/frontend/fixtures-ee/graphql/ai/duo_agentic_chat/');
export const fixtures = loadFixturesMap(FIXTURES_PATH);

// Derive test constants from fixture data so the spec does not need to
// hardcode IDs that only exist at fixture-generation time.
const workflowNode = fixtures.getWorkflowLatestCheckpoint?.data?.duoWorkflowWorkflows?.nodes?.[0];
export const MOCK_WORKFLOW_GID = workflowNode?.id;
export const MOCK_WORKFLOW_NUMERIC_ID = workflowNode ? parseGid(MOCK_WORKFLOW_GID)?.id : null;

export function handleDuoAgenticChatOperation({ operationName, res, ctx }) {
  const fixture = fixtures[operationName];
  if (!fixture) return null;
  return res(ctx.json(fixture));
}
