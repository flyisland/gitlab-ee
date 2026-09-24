import { s__ } from '~/locale';
import { placeholderForType as eePlaceholderForType } from 'ee/integrations/constants';

/* eslint-disable import/export */
export * from 'ee/integrations/constants';

const INTEGRATION_TYPE_FEISHU = 'feishu';

export const placeholderForType = {
  ...eePlaceholderForType,
  [INTEGRATION_TYPE_FEISHU]: s__(
    'JH|INTEGRATION|Dev Group, Ops Group(Feishu group names separated by comma)',
  ),
};
