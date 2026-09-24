import { s__, __ } from '~/locale';

export const monorepoItemI18n = {
  mergeable: s__('JH|Monorepo|mergeable'),
};

export const monorepoI18n = {
  mergeAll: s__('JH|Monorepo|Merge all'),
  readyToMerge: __('Ready to merge!'),
  pendingMergeRequests: s__('JH|Monorepo|There are %{count} unapproved %{merge_request}'),
  mergeInQueue: s__(
    'JH|Monorepo|There is 1 merging function in process, branch name is %{branch_name}',
  ),
  lastMergeFailed: s__('JH|Monorepo|Merge blocked: unsuccessful merge request(s) found'),
  dispatchMergeError: s__(
    'JH|Monorepo|Error while dispatching the merge request, please try again.',
  ),
  mergedByUser: s__('JH|Monorepo|All related MR(s) are merged by'),
};

export const MONO_ITEM_STATUS_CLOSED = 'closed';
export const MONO_ITEM_STATUS_MERGED = 'merged';

export const CAN_MERGE = 'can_be_merged';
export const CANNOT_MERGE = 'cannot_be_merged';
export const MERGED = 'merged';
export const MERGING = 'merging';
export const CLOSED = 'closed';

export const mrStateI18n = {
  [MONO_ITEM_STATUS_MERGED]: __('Merged'),
  [MONO_ITEM_STATUS_CLOSED]: __('Closed'),
};

export const mrStateVariants = {
  [MONO_ITEM_STATUS_MERGED]: 'info',
  [MONO_ITEM_STATUS_CLOSED]: 'danger',
};

export const MONOREPO_MR_LIST_QUERY_POLLING_INTERVAL_DEFAULT = 10000;
