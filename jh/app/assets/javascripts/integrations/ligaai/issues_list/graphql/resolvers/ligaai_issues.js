import { DEFAULT_PAGE_SIZE } from '~/vue_shared/issuable/list/constants';
import { i18n } from '~/work_items/list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const transformLigaaiIssueAssignees = (ligaaiIssue) => {
  return ligaaiIssue.assignees.map((assignee) => ({
    __typename: 'UserCore',
    ...assignee,
  }));
};

const transformLigaaiIssueAuthor = (ligaaiIssue, authorId) => {
  return {
    __typename: 'UserCore',
    ...ligaaiIssue.author,
    id: authorId,
  };
};

const transformLigaaiIssueLabels = (ligaaiIssue) => {
  return ligaaiIssue.labels.map((label) => ({
    __typename: 'Label',
    ...label,
  }));
};

const transformLigaaiIssuePageInfo = (responseHeaders = {}) => {
  return {
    __typename: 'LigaaiIssuesPageInfo',
    page: parseInt(responseHeaders['x-page'], 10) ?? 1,
    total: parseInt(responseHeaders['x-total'], 10) ?? 0,
  };
};

export const transformLigaaiIssuesREST = (response) => {
  const { headers, data: ligaaiIssues } = response;

  return {
    __typename: 'LigaaiIssues',
    errors: [],
    pageInfo: transformLigaaiIssuePageInfo(headers),
    nodes: ligaaiIssues.map((rawIssue, index) => {
      const ligaaiIssue = convertObjectPropsToCamelCase(rawIssue, { deep: true });
      return {
        __typename: 'LigaaiIssue',
        ...ligaaiIssue,
        id: rawIssue.id,
        author: transformLigaaiIssueAuthor(ligaaiIssue, index),
        labels: transformLigaaiIssueLabels(ligaaiIssue),
        assignees: transformLigaaiIssueAssignees(ligaaiIssue),
      };
    }),
  };
};

export default function ligaaiIssuesResolver(
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
      return transformLigaaiIssuesREST(res);
    })
    .catch((error) => {
      return {
        __typename: 'LigaaiIssues',
        errors: error?.response?.data?.errors || [i18n.errorFetchingIssues],
        pageInfo: transformLigaaiIssuePageInfo(),
        nodes: [],
      };
    });
}
