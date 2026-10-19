import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import {
  PERFORMANCE_TYPE_CLOSED_ISSUES,
  PERFORMANCE_TYPE_COMMITS_NUMBER,
  PERFORMANCE_TYPE_MERGED_REQUESTS,
  PERFORMANCE_TYPE_PER_CAPITA_COMMITS,
} from 'jh/analytics/performance_analytics/constants';

export const group = {
  group_id: 1,
  full_path: 'foo',
  is_group: true,
};

export const currentGroup = convertObjectPropsToCamelCase(group, { deep: true });

export const mockSelectedProjects = [
  {
    id: 'gid://gitlab/Project/1',
    name: 'cool project',
    pathWithNamespace: 'group/cool-project',
    avatarUrl: null,
  },
  {
    id: 'gid://gitlab/Project/2',
    name: 'another cool project',
    pathWithNamespace: 'group/another-cool-project',
    avatarUrl: null,
  },
];

export const mockDefaultBranch = 'master';

export const mockIndicatorList = [
  {
    key: PERFORMANCE_TYPE_CLOSED_ISSUES,
    index: 0,
  },
  {
    key: PERFORMANCE_TYPE_COMMITS_NUMBER,
    index: 1,
  },
  {
    key: PERFORMANCE_TYPE_MERGED_REQUESTS,
    index: 2,
  },
  {
    key: PERFORMANCE_TYPE_PER_CAPITA_COMMITS,
    index: 3,
  },
];

export const rankDropdownDefaultValue = PERFORMANCE_TYPE_COMMITS_NUMBER;

export const groupRankDropdownDefaultValue = PERFORMANCE_TYPE_COMMITS_NUMBER;

export const mockSelectedDate = {
  startDate: new Date('2022-05-01'),
  endDate: new Date('2022-05-06'),
};

export const mockSummaryData = {
  issues_closed: 10,
  commits_pushed: 10,
  merge_requests_merged: 100,
  commits_pushed_per_capita: 100,
};

export const mockReportSummary = {
  commits_pushed: 0,
  issues_created: 0,
  issues_closed: 0,
  merge_requests_created: 0,
  merge_requests_approved: 0,
  merge_requests_merged: 0,
  merge_requests_closed: 0,
  notes_created: 0,
};
export const mockReportSummaryState = convertObjectPropsToCamelCase(mockReportSummary);

export const mockRankList = [
  {
    user: {
      fullname: 'YukCummings1',
      username: 'julee1',
      user_web_url: '/julee1',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    rank: 1,
    value: 100,
  },
  {
    user: {
      fullname: 'YukCummings2',
      username: 'julee2',
      user_web_url: '/julee2',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    rank: 2,
    value: 100,
  },
  {
    user: {
      fullname: 'YukCummings3',
      username: 'julee3',
      user_web_url: '/julee3',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    rank: 3,
    value: 100,
  },
  {
    user: {
      fullname: 'YukCummings4',
      username: 'jule4',
      user_web_url: '/julee4',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    rank: 4,
    value: 100,
  },
  {
    user: {
      fullname: 'YukCummings5',
      username: 'jule5',
      user_web_url: '/julee5',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    rank: 5,
    value: 100,
  },
];

export const mockPerformanceTable = [
  {
    user: {
      fullname: 'YukCummings1',
      username: 'julee1',
      user_web_url: '/julee1',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
  {
    user: {
      fullname: 'YukCummings2',
      username: 'julee2',
      user_web_url: '/julee2',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
  {
    user: {
      fullname: 'YukCummings3',
      username: 'julee3',
      user_web_url: '/julee3',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
  {
    user: {
      fullname: 'YukCummings4',
      username: 'julee4',
      user_web_url: '/julee4',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
  {
    user: {
      fullname: 'YukCummings5',
      username: 'julee5',
      user_web_url: '/julee5',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
  {
    user: {
      fullname: 'YukCummings6',
      username: 'julee6',
      user_web_url: '/julee6',
      avatar: 'https://www.gravatar.com/avatar/d55ac6fc02672f37d9fbd69cb2a64b9b?s=80&d=identicon',
    },
    commits_pushed: 0,
    issues_closed: 0,
    issues_created: 0,
    merge_requests_approved: 0,
    merge_requests_closed: 0,
    merge_requests_created: 0,
    merge_requests_merged: 0,
    notes_created: 0,
  },
];
