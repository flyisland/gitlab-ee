import mockData, { mockStore } from 'jest/vue_merge_request_widget/mock_data';

export default {
  ...mockData,
  can_read_vulnerabilities: true,
  enabled_reports: {
    sast: false,
    container_scanning: false,
    dast: false,
    dependency_scanning: false,
    license_management: false,
    secret_detection: false,
  },
  discover_project_security_path: '/discover_project_security',
  merge_immediately_docs_path: '/merge_immediately_docs',
  container_scanning_comparison_path: '/container_scanning_comparison_path',
  dependency_scanning_comparison_path: '/dependency_scanning_comparison_path',
  dast_comparison_path: '/dast_comparison_path',
  coverage_fuzzing_comparison_path: '/coverage_fuzzing_comparison_path',
  api_fuzzing_comparison_path: '/api_fuzzing_comparison_path',
};

// Browser Performance Testing
export const headBrowserPerformance = [
  {
    subject: '/some/path',
    metrics: [
      {
        name: 'Total Score',
        value: 80,
        desiredSize: 'larger',
      },
      {
        name: 'Requests',
        value: 30,
        desiredSize: 'smaller',
      },
      {
        name: 'Speed Index',
        value: 1155,
        desiredSize: 'smaller',
      },
      {
        name: 'Transfer Size (KB)',
        value: '1070.1',
        desiredSize: 'smaller',
      },
    ],
  },
];

export const baseBrowserPerformance = [
  {
    subject: '/some/path',
    metrics: [
      {
        name: 'Total Score',
        value: 82,
        desiredSize: 'larger',
      },
      {
        name: 'Requests',
        value: 30,
        desiredSize: 'smaller',
      },
      {
        name: 'Speed Index',
        value: 1165,
        desiredSize: 'smaller',
      },
      {
        name: 'Transfer Size (KB)',
        value: '1065.1',
        desiredSize: 'smaller',
      },
    ],
  },
];

// Load Performance Testing
export const headLoadPerformance = {
  metrics: {
    checks: {
      fails: 0,
      passes: 45,
      value: 0,
    },
    http_req_waiting: {
      avg: 104.3543911111111,
      max: 247.8693,
      med: 99.1985,
      min: 98.1397,
      'p(90)': 100.60016,
      'p(95)': 125.45588000000023,
    },
    http_reqs: {
      count: 45,
      rate: 8.999484329547917,
    },
  },
};

export const baseLoadPerformance = {
  metrics: {
    checks: {
      fails: 0,
      passes: 39,
      value: 0,
    },
    http_req_waiting: {
      avg: 118.28965641025643,
      max: 674.4383,
      med: 98.2503,
      min: 97.1357,
      'p(90)': 104.09862000000001,
      'p(95)': 101.22848,
    },
    http_reqs: {
      count: 39,
      rate: 7.799590989448514,
    },
  },
};

export const codequalityParsedIssues = [
  {
    name: 'Insecure Dependency',
    fingerprint: 'ca2e59451e98ae60ba2f54e3857c50e5',
    path: 'Gemfile.lock',
    line: 12,
    urlPath: 'foo/Gemfile.lock',
    severity: 'minor',
  },
];

export { mockStore };

export const mockMonorepoMr = {
  breadcrumbs: [
    {
      text: 'Item 1',
      href: '#',
    },
    {
      text: 'Item 2',
      href: '#',
    },
    {
      text: 'Item 3',
      href: '#',
    },
    {
      text: 'Item 4',
      href: '#',
    },
    {
      text: 'Item 5',
      href: '#',
    },
  ],
  title: 'MR-A',
  path: '/flightjs/Flight/-/merge_requests/13',
  merge_error: null,
  mergeable: true,
  state: 'opened',
  head_pipeline: {
    icon: 'status_warning',
    text: '警告',
    label: '已通过但有警告',
    group: 'success-with-warnings',
    tooltip: '已通过',
    has_details: true,
    details_path: '/gitlab-org/gitlab-shell/-/pipelines/1',
    illustration: null,
    favicon:
      '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
  },
  approvals_given: 2,
  approvals_left: 1,
};

export const mockMonorepoMrWidgetData = {
  merge_requests_list_status: 'can_be_merged',
  has_permission_to_merge: true,
  other_merging_topic_label_name: null,
  merge_requests: [mockMonorepoMr],
};

export const mockMergedAtTime = '2023-08-15T03:32:16.016Z';
export const mockMergedByUser = {
  id: 1,
  username: 'root',
  name: 'Administrator',
  state: 'active',
  avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
  web_url: 'http://127.0.0.1:3000/root',
  show_status: false,
  path: '/root',
};

export const mockCentralPipeline = {
  id: 626,
  active: false,
  name: null,
  path: '/rootgroup/monorepo-ci-project/-/pipelines/626',
  flags: {
    merge_request_pipeline: false,
  },
  commit: {
    id: '2fcd06e8bcc1abe9aeb391cbd6b7da7236081ee3',
    short_id: '2fcd06e8',
    created_at: '2023-09-06T14:22:48.000+00:00',
    parent_ids: ['dea16ed8842f7431b0dda8ff8f83eb74cad1387c'],
    title: 'Update file .gitlab-ci.yml',
    message: 'Update file .gitlab-ci.yml',
    author_name: 'Administrator',
    author_email: 'root-work@example.com',
    authored_date: '2023-09-06T14:22:48.000+00:00',
    committer_name: 'Administrator',
    committer_email: 'admin@example.com',
    committed_date: '2023-09-06T14:22:48.000+00:00',
    trailers: {},
    web_url:
      'http://127.0.0.1:3000/rootgroup/monorepo-ci-project/-/commit/2fcd06e8bcc1abe9aeb391cbd6b7da7236081ee3',
    author: {
      id: 1,
      username: 'root',
      name: 'Administrator',
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      web_url: 'http://127.0.0.1:3000/root',
      show_status: false,
      path: '/root',
    },
    author_gravatar_url:
      'https://www.gravatar.com/avatar/08e97d2d0efb787136436bb00bfed50c?s=80&d=identicon',
    commit_url:
      'http://127.0.0.1:3000/rootgroup/monorepo-ci-project/-/commit/2fcd06e8bcc1abe9aeb391cbd6b7da7236081ee3',
    commit_path: '/rootgroup/monorepo-ci-project/-/commit/2fcd06e8bcc1abe9aeb391cbd6b7da7236081ee3',
  },
  details: {
    event_type_name: 'Pipeline',
    artifacts: [],
    status: {
      icon: 'status_success',
      text: 'passed',
      label: 'passed',
      group: 'success',
      tooltip: 'passed',
      has_details: true,
      details_path: '/rootgroup/monorepo-ci-project/-/pipelines/626',
      illustration: null,
      favicon:
        '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
    },
    stages: [
      {
        name: 'test',
        title: 'test: passed',
        status: {
          icon: 'status_success',
          text: 'passed',
          label: 'passed',
          group: 'success',
          tooltip: 'passed',
          has_details: true,
          details_path: '/rootgroup/monorepo-ci-project/-/pipelines/626#test',
          illustration: null,
          favicon:
            '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
        },
        path: '/rootgroup/monorepo-ci-project/-/pipelines/626#test',
        dropdown_path: '/rootgroup/monorepo-ci-project/-/pipelines/626/stage.json?stage=test',
      },
    ],
    finished_at: '2023-09-06T14:33:06.905Z',
  },
  coverage: null,
  ref: {
    branch: true,
  },
  triggered_by: null,
  triggered: [],
};
