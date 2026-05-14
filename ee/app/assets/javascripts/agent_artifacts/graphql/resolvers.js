/* eslint-disable @gitlab/require-i18n-strings */
/* eslint-disable @gitlab/no-hardcoded-urls */
const MOCK_ITEMS = [
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
    name: 'SAST False Positive Detection',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
      webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions',
    },
    auditEvents: { count: 4 },
    creditsUsed: 1247,
    project: {
      id: 'gid://gitlab/Project/278964',
      name: 'Security Scanner and Vulnerability Detection System for Enterprise Applications with Multi-Region Support',
      webPath: '/gitlab-org/security-scanner',
    },
    startTime: '2026-03-05T22:14:17Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228929', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228929 in project 278964',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Build review context for merge request !228929 in project 278964 (diffs only)',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2',
    name: 'Code Review',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1909',
      webPath: '/gitlab-org/frontend-app/-/automate/agent-sessions',
    },
    auditEvents: { count: 7 },
    creditsUsed: 543,
    project: {
      id: 'gid://gitlab/Project/278965',
      name: 'Frontend App',
      webPath: '/gitlab-org/frontend-app',
    },
    startTime: '2026-03-05T21:30:45Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228931', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228931 in project 278965',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file src/components/Button.vue from project 278965 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/3',
    name: 'Developer',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1910',
      webPath: '/gitlab-org/api-service/-/automate/agent-sessions',
    },
    auditEvents: { count: 2 },
    creditsUsed: 892,
    project: {
      id: 'gid://gitlab/Project/278966',
      name: 'API Service',
      webPath: '/gitlab-org/api-service',
    },
    startTime: '2026-03-05T20:45:12Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228933', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228933 in project 278966',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'List repository tree recursively in path "docs/" in project 278966',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/4',
    name: 'Fix CI/CD Pipeline',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1911',
      webPath: '/gitlab-org/backend-service/-/automate/agent-sessions',
    },
    auditEvents: { count: 5 },
    creditsUsed: 324,
    project: {
      id: 'gid://gitlab/Project/278967',
      name: 'Backend Service',
      webPath: '/gitlab-org/backend-service',
    },
    startTime: '2026-03-05T19:22:38Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228935', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228935 in project 278967',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file spec/models/user_spec.rb from project 278967 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/5',
    name: 'Resolve SAST Vulnerability',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1912',
      webPath: '/gitlab-org/security-tools/-/automate/agent-sessions',
    },
    auditEvents: { count: 9 },
    creditsUsed: 1876,
    project: {
      id: 'gid://gitlab/Project/278968',
      name: 'Security Tools and Advanced Threat Protection Platform for Cloud Native Applications and Microservices',
      webPath: '/gitlab-org/security-tools',
    },
    startTime: '2026-03-05T18:10:55Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228937', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228937 in project 278968',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Build review context for merge request !228937 in project 278968 (lightweight)',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228937 in project 278968',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/6',
    name: 'AI Catalog Agent',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1913',
      webPath: '/gitlab-org/platform-services/-/automate/agent-sessions',
    },
    auditEvents: { count: 6 },
    creditsUsed: 678,
    project: {
      id: 'gid://gitlab/Project/278969',
      name: 'Platform Services',
      webPath: '/gitlab-org/platform-services',
    },
    startTime: '2026-03-05T17:45:30Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228939', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228939 in project 278969',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file lib/performance/metrics.rb from project 278969 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228939 in project 278969',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/7',
    name: 'Secret Detection False Positive Detection',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1914',
      webPath: '/gitlab-org/data-platform/-/automate/agent-sessions',
    },
    auditEvents: { count: 3 },
    creditsUsed: 445,
    project: {
      id: 'gid://gitlab/Project/278970',
      name: 'Data Platform',
      webPath: '/gitlab-org/data-platform',
    },
    startTime: '2026-03-05T16:20:15Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228941', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228941 in project 278970',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content:
            'Get repository file db/migrate/20260305_add_index.rb from project 278970 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228941 in project 278970',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/8',
    name: 'Code Review',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1915',
      webPath: '/gitlab-org/rest-api-service/-/automate/agent-sessions',
    },
    auditEvents: { count: 8 },
    creditsUsed: 923,
    project: {
      id: 'gid://gitlab/Project/278971',
      name: 'REST API Service',
      webPath: '/gitlab-org/rest-api-service',
    },
    startTime: '2026-03-05T15:55:42Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228943', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228943 in project 278971',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content:
            'Get repository file app/controllers/api/v1/users_controller.rb from project 278971 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228943 in project 278971',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/9',
    name: 'Developer',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1916',
      webPath: '/gitlab-org/design-system/-/automate/agent-sessions',
    },
    auditEvents: { count: 4 },
    creditsUsed: 567,
    project: {
      id: 'gid://gitlab/Project/278972',
      name: 'Design System',
      webPath: '/gitlab-org/design-system',
    },
    startTime: '2026-03-05T14:30:28Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228945', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228945 in project 278972',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file src/components/Card.vue from project 278972 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228945 in project 278972',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/10',
    name: 'SAST False Positive Detection',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1917',
      webPath: '/gitlab-org/monitoring-tools/-/automate/agent-sessions',
    },
    auditEvents: { count: 11 },
    creditsUsed: 1534,
    project: {
      id: 'gid://gitlab/Project/278973',
      name: 'Monitoring Tools and Observability Platform for Large Scale Distributed Infrastructure and Cloud Services',
      webPath: '/gitlab-org/monitoring-tools',
    },
    startTime: '2026-03-05T13:12:05Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228947', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228947 in project 278973',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content:
            'Get repository file lib/monitoring/error_parser.rb from project 278973 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228947 in project 278973',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/11',
    name: 'Fix CI/CD Pipeline',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1918',
      webPath: '/gitlab-org/cloud-infrastructure/-/automate/agent-sessions',
    },
    auditEvents: { count: 5 },
    creditsUsed: 789,
    project: {
      id: 'gid://gitlab/Project/278974',
      name: 'Cloud Infrastructure',
      webPath: '/gitlab-org/cloud-infrastructure',
    },
    startTime: '2026-03-05T12:45:50Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228949', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228949 in project 278974',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file terraform/main.tf from project 278974 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228949 in project 278974',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/12',
    name: 'AI Catalog Agent',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1919',
      webPath: '/gitlab-org/cicd-pipeline/-/automate/agent-sessions',
    },
    auditEvents: { count: 7 },
    creditsUsed: 1123,
    project: {
      id: 'gid://gitlab/Project/278975',
      name: 'CI/CD Pipeline',
      webPath: '/gitlab-org/cicd-pipeline',
    },
    startTime: '2026-03-05T11:22:37Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228950', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228950 in project 278975',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file .gitlab-ci.yml from project 278975 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228950 in project 278975',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/13',
    name: 'Secret Detection False Positive Detection',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1920',
      webPath: '/gitlab-org/config-service/-/automate/agent-sessions',
    },
    auditEvents: { count: 3 },
    creditsUsed: 412,
    project: {
      id: 'gid://gitlab/Project/278976',
      name: 'Config Service',
      webPath: '/gitlab-org/config-service',
    },
    startTime: '2026-03-05T10:15:22Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228951', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228951 in project 278976',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file config/application.yml from project 278976 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228951 in project 278976',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/14',
    name: 'Resolve SAST Vulnerability',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1921',
      webPath: '/gitlab-org/legacy-codebase/-/automate/agent-sessions',
    },
    auditEvents: { count: 9 },
    creditsUsed: 1345,
    project: {
      id: 'gid://gitlab/Project/278977',
      name: 'Legacy Codebase',
      webPath: '/gitlab-org/legacy-codebase',
    },
    startTime: '2026-03-05T09:40:11Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228952', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228952 in project 278977',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Get repository file app/models/legacy_user.rb from project 278977 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228952 in project 278977',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/15',
    name: 'Code Review',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1922',
      webPath: '/gitlab-org/security-compliance/-/automate/agent-sessions',
    },
    auditEvents: { count: 12 },
    creditsUsed: 2145,
    project: {
      id: 'gid://gitlab/Project/278978',
      name: 'Security Compliance and Regulatory Framework Management System for Financial Services and Healthcare',
      webPath: '/gitlab-org/security-compliance',
    },
    startTime: '2026-03-05T08:25:48Z',
    latestCheckpoint: {
      duoMessages: [
        { content: 'Starting Flow: 228953', messageType: 'tool', __typename: 'DuoMessage' },
        {
          content: 'Build review context for merge request !228953 in project 278978',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content:
            'Get repository file lib/compliance/audit_logger.rb from project 278978 at ref HEAD',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
        {
          content: 'Post Duo Code Review to merge request !228953 in project 278978',
          messageType: 'tool',
          __typename: 'DuoMessage',
        },
      ],
    },
    __typename: 'AiItem',
  },
];

const PAGE_SIZE = 10;

export const resolvers = {
  Query: {
    aiItems: (_, { after, before, first = PAGE_SIZE, last, name, not }) => {
      let filteredItems = MOCK_ITEMS;

      if (name) {
        filteredItems = filteredItems.filter((item) => item.name === name);
      }

      if (not?.name) {
        filteredItems = filteredItems.filter((item) => item.name !== not.name);
      }

      let startIndex = 0;
      let endIndex = filteredItems.length;

      if (after) {
        const afterIndex = filteredItems.findIndex((item) => item.id === after);
        if (afterIndex !== -1) {
          startIndex = afterIndex + 1;
        }
      }

      if (before) {
        const beforeIndex = filteredItems.findIndex((item) => item.id === before);
        if (beforeIndex !== -1) {
          endIndex = beforeIndex;
        }
      }

      let slicedItems;
      let hasNextPage;
      let hasPreviousPage;

      if (last) {
        const sliceStart = Math.max(startIndex, endIndex - last);
        slicedItems = filteredItems.slice(sliceStart, endIndex);
        hasNextPage = endIndex < filteredItems.length;
        hasPreviousPage = sliceStart > 0;
      } else {
        const sliceEnd = Math.min(startIndex + first, endIndex);
        slicedItems = filteredItems.slice(startIndex, sliceEnd);
        hasNextPage = sliceEnd < filteredItems.length;
        hasPreviousPage = startIndex > 0;
      }

      return {
        count: filteredItems.length,
        nodes: slicedItems,
        pageInfo: {
          startCursor: slicedItems[0]?.id || null,
          endCursor: slicedItems[slicedItems.length - 1]?.id || null,
          hasNextPage,
          hasPreviousPage,
          __typename: 'PageInfo',
        },
        __typename: 'AiItemConnection',
      };
    },
  },
};

export default resolvers;
