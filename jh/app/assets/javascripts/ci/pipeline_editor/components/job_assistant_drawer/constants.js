import EMPTY_PIPELINE_MD from '@gitlab/svgs/dist/illustrations/empty-state/empty-pipeline-md.svg?url';
import { DOCS_URL_IN_EE_DIR } from 'jh/lib/utils/url_utility';
import * as originalConstants from '~/ci/pipeline_editor/components/job_assistant_drawer/constants';
import { __, s__ } from '~/locale';

export {
  JOB_TEMPLATE,
  SECONDS_MULTIPLE_MAP,
  JOB_RULES_START_IN,
  JOB_RULES_WHEN,
} from '~/ci/pipeline_editor/components/job_assistant_drawer/constants';

export const i18n = {
  ...originalConstants.i18n,
  DESCRIPTION: __('Description'),
  TEMPLATE_NAME: s__('JH|JobAssistant|Template name'),
  JOB_TEMPLATE: s__('JH|JobAssistant|Job template'),
  BLANK_TEMPLATE: s__('JH|JobAssistant|Blank template'),
  GETTING_STARTED_WITH_JOB_TEMPLATE: s__('JH|JobAssistant|Getting started with job template'),
  CREATE_NEW_TEMPLATE: s__('JH|JobAssistant|Create a new job template'),
  LEARN_MORE: s__('JH|JobAssistant|Learn more about job template'),
  EMPTY_STATE_DESCRIPTION: s__(
    'JH|JobAssistant|Using the job template can quickly insert the corresponding job in the yml file, so that the editing efficiency of the pipeline is greatly improved.',
  ),
  TEMPLATE_LIST_ERROR: __('Something went wrong. Please try again.'),
};

export const HELP_PATHS = {
  ...originalConstants.HELP_PATHS,
  jobHelpPath: `${DOCS_URL_IN_EE_DIR}/ci/jobs`,
};

export const EMPTY_STATE_SVG_PATH = EMPTY_PIPELINE_MD;
