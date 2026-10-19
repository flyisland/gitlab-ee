import { handleWorkItemOperation, workItemRestEndpoints } from './work_items/handlers';
import { handleAiCatalogOperation, aiCatalogRestEndpoints } from './ai_catalog/handlers';
import { handleCdEnvironmentOperation, cdEnvironmentRestEndpoints } from './cd/handlers';
import { handleCommitListOperation, commitListRestEndpoints } from './commits/handlers';
import {
  handleSecurityPolicyOperation,
  securityPolicyRestEndpoints,
} from './security_policies/handlers';
import { handlePipelineEditorOperation, pipelineEditorRestEndpoints } from './ci/handlers';
import { handleCiCatalogOperation, ciCatalogRestEndpoints } from './ci/catalog/handlers';
import { handleRepositoryOperation, repositoryRestEndpoints } from './repository/handlers';
import {
  handlePipelineSecurityOperation,
  pipelineSecurityRestEndpoints,
} from './ci/pipelines/handlers';
import {
  handleAnalyticsDashboardOperation,
  analyticsDashboardRestEndpoints,
} from './analytics_dashboards/handlers';
import { handleAdminJobsOperation, adminJobsRestEndpoints } from './ci/admin_jobs/handlers';

export { buildHandlers } from '@gitlab/frontend-tests/integration';

// Keyed on the GraphQL operation name alone, so the first handler to claim an operation wins
// and a domain missing its own fixture silently gets an earlier domain's payload.
export const featureHandlers = [
  handleWorkItemOperation,
  handleAiCatalogOperation,
  handleCdEnvironmentOperation,
  handleCommitListOperation,
  handleSecurityPolicyOperation,
  handlePipelineEditorOperation,
  handleCiCatalogOperation,
  handleRepositoryOperation,
  handlePipelineSecurityOperation,
  handleAnalyticsDashboardOperation,
  handleAdminJobsOperation,
];
export const restEndpoints = [
  ...workItemRestEndpoints,
  ...aiCatalogRestEndpoints,
  ...cdEnvironmentRestEndpoints,
  ...commitListRestEndpoints,
  ...securityPolicyRestEndpoints,
  ...pipelineEditorRestEndpoints,
  ...ciCatalogRestEndpoints,
  ...repositoryRestEndpoints,
  ...pipelineSecurityRestEndpoints,
  ...analyticsDashboardRestEndpoints,
  ...adminJobsRestEndpoints,
];
