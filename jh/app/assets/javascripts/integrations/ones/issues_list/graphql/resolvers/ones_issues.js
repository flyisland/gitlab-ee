import { DEFAULT_PAGE_SIZE } from '~/vue_shared/issuable/list/constants';
import { i18n } from '~/work_items/list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const transformOnesIssueAssignees = (onesIssue) => {
  return onesIssue.assignees.map((assignee) => ({
    __typename: 'UserCore',
    ...assignee,
  }));
};

const transformOnesIssueAuthor = (onesIssue, authorId) => {
  return {
    __typename: 'UserCore',
    ...onesIssue.author,
    id: authorId,
  };
};

const transformOnesIssueLabels = (onesIssue) => {
  return onesIssue.labels.map((label) => ({
    __typename: 'Label',
    ...label,
  }));
};

const transformOnesIssuePageInfo = (responseHeaders = {}) => {
  return {
    __typename: 'OnesIssuesPageInfo',
    page: parseInt(responseHeaders['x-page'], 10) ?? 1,
    total: parseInt(responseHeaders['x-total'], 10) ?? 0,
  };
};

export const transformOnesIssuesREST = (response) => {
  const { headers, data: onesIssues } = response;

  return {
    __typename: 'OnesIssues',
    errors: [],
    pageInfo: transformOnesIssuePageInfo(headers),
    nodes: onesIssues.map((rawIssue, index) => {
      const onesIssue = convertObjectPropsToCamelCase(rawIssue, { deep: true });
      return {
        __typename: 'OnesIssue',
        ...onesIssue,
        id: rawIssue.id,
        author: transformOnesIssueAuthor(onesIssue, index),
        labels: transformOnesIssueLabels(onesIssue),
        assignees: transformOnesIssueAssignees(onesIssue),
      };
    }),
  };
};

export default function onesIssuesResolver(
  _,
  { issuesFetchPath, search, page, state, sort, labels },
) {
  return axios
    .get(issuesFetchPath, {
      params: {
        limit: DEFAULT_PAGE_SIZE,
        page,
        state,
        sort,
        labels,
        search,
      },
    })
    .then((res) => {
      return transformOnesIssuesREST(res);
    })
    .catch((error) => {
      return {
        __typename: 'OnesIssues',
        errors: error?.response?.data?.errors || [i18n.errorFetchingIssues],
        pageInfo: transformOnesIssuePageInfo(),
        nodes: [],
      };
    });
}
