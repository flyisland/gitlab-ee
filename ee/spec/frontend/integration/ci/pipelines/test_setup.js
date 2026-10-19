import Vue from 'vue';
import VueRouter from 'vue-router';
import {
  assignRouter,
  findButtonByText,
  registerBootstrappedApp,
  screen,
} from 'ee_jest/integration/helpers/test_helpers';
import { createAppOptions } from 'ee/ci/pipeline_details/pipeline_tabs';
import { routes } from 'ee/ci/pipeline_details/routes';
import { apolloProvider } from '~/ci/pipeline_details/pipeline_shared_client';

const PROJECT_FULL_PATH = 'frontend-fixtures/project';
const PIPELINE_IID = '1';
const PIPELINE_PATH = `/${PROJECT_FULL_PATH}/-/pipelines/${PIPELINE_IID}`;

const DATASET = {
  exposeSecurityDashboard: 'true',
  failedJobsCount: '0',
  pipelineIid: PIPELINE_IID,
  pipelinePath: PIPELINE_PATH,
  projectPath: PROJECT_FULL_PATH,
  sbomReportsErrors: '[]',
  testsCount: '0',
  totalJobCount: '1',
  vulnerabilityReportData: JSON.stringify({
    project_full_path: PROJECT_FULL_PATH,
    pipeline_id: PIPELINE_IID,
    pipeline_iid: PIPELINE_IID,
    can_admin_vulnerability: 'true',
    can_view_false_positive: 'false',
    has_vulnerabilities: 'true',
  }),
};

export function mountPipelineSecurityTab() {
  const router = assignRouter(
    () => new VueRouter({ mode: 'history', base: PIPELINE_PATH, routes }),
    { routerLocation: `${PIPELINE_PATH}/security` },
  );

  const el = document.createElement('div');
  el.id = 'js-pipeline-tabs';
  Object.assign(el.dataset, DATASET);
  document.body.appendChild(el);

  return registerBootstrappedApp(
    new Vue(createAppOptions('#js-pipeline-tabs', apolloProvider, router)),
  );
}

export const findPageDescription = () => screen.queryByTestId('page-description');

export const findFindings = () => [...screen.queryAllByTestId('vulnerability')];

export const findNextButton = () => findButtonByText('Next');
