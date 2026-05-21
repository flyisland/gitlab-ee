/* eslint-disable @gitlab/require-i18n-strings */
/* eslint-disable @gitlab/no-hardcoded-urls */

const MOCK_AUTHOR = {
  id: 'gid://gitlab/User/1',
  name: 'Scott Hampton',
  username: 'shampton',
  avatarUrl: 'https://gitlab.com/uploads/-/system/user/avatar/3029776/avatar.png',
  webPath: '/shampton',
  __typename: 'UserCore',
};

const MOCK_AUDIT_EVENTS = [
  {
    id: 'event-1',
    eventType: 'AI agent session started',
    createdAt: '2026-05-04T10:30:00Z',
    author: MOCK_AUTHOR,
    __typename: 'AuditEvent',
  },
  {
    id: 'event-2',
    eventType: 'AI LLM input sent',
    createdAt: '2026-05-04T10:31:00Z',
    author: MOCK_AUTHOR,
    __typename: 'AuditEvent',
  },
  {
    id: 'event-3',
    eventType: 'Create AI catalog agent',
    createdAt: '2026-05-04T10:32:00Z',
    author: MOCK_AUTHOR,
    __typename: 'AuditEvent',
  },
  {
    id: 'event-4',
    eventType: 'Enable AI catalog agent',
    createdAt: '2026-05-04T10:33:00Z',
    author: MOCK_AUTHOR,
    __typename: 'AuditEvent',
  },
  {
    id: 'event-5',
    eventType: 'An LLM response received',
    createdAt: '2026-05-04T10:34:00Z',
    author: MOCK_AUTHOR,
    __typename: 'AuditEvent',
  },
];

const AUDIT_EVENTS_PAGE_SIZE = 5;

const MOCK_ITEMS = [
  {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
    name: 'SAST False Positive Detection',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
      webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions',
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 4 },
    creditsUsed: 1247,
    project: {
      id: 'gid://gitlab/Project/278964',
      name: 'Demo SAST FP Detection',
      webPath: '/gitlab-duo/demo-sast-fp-detection',
      fullPath: 'gitlab-duo/demo-sast-fp-detection',
    },
    startTime: '2026-04-12T22:14:17Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 7 },
    creditsUsed: 543,
    project: {
      id: 'gid://gitlab/Project/278965',
      name: 'Frontend App',
      webPath: '/gitlab-org/frontend-app',
      fullPath: 'gitlab-org/frontend-app',
    },
    startTime: '2026-02-28T21:30:45Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 2 },
    creditsUsed: 892,
    project: {
      id: 'gid://gitlab/Project/278966',
      name: 'API Service',
      webPath: '/gitlab-org/api-service',
      fullPath: 'gitlab-org/api-service',
    },
    startTime: '2026-01-15T20:45:12Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 5 },
    creditsUsed: 324,
    project: {
      id: 'gid://gitlab/Project/278967',
      name: 'Backend Service',
      webPath: '/gitlab-org/backend-service',
      fullPath: 'gitlab-org/backend-service',
    },
    startTime: '2026-03-22T19:22:38Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 9 },
    creditsUsed: 1876,
    project: {
      id: 'gid://gitlab/Project/278968',
      name: 'Security Tools and Advanced Threat Protection Platform for Cloud Native Applications and Microservices',
      webPath: '/gitlab-org/security-tools',
      fullPath: 'gitlab-org/security-tools',
    },
    startTime: '2026-02-10T18:10:55Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 6 },
    creditsUsed: 678,
    project: {
      id: 'gid://gitlab/Project/278969',
      name: 'Platform Services',
      webPath: '/gitlab-org/platform-services',
      fullPath: 'gitlab-org/platform-services',
    },
    startTime: '2025-12-20T17:45:30Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 3 },
    creditsUsed: 445,
    project: {
      id: 'gid://gitlab/Project/278970',
      name: 'Data Platform',
      webPath: '/gitlab-org/data-platform',
      fullPath: 'gitlab-org/data-platform',
    },
    startTime: '2026-04-05T16:20:15Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 8 },
    creditsUsed: 923,
    project: {
      id: 'gid://gitlab/Project/278971',
      name: 'REST API Service',
      webPath: '/gitlab-org/rest-api-service',
      fullPath: 'gitlab-org/rest-api-service',
    },
    startTime: '2026-01-30T15:55:42Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 4 },
    creditsUsed: 567,
    project: {
      id: 'gid://gitlab/Project/278972',
      name: 'Design System',
      webPath: '/gitlab-org/design-system',
      fullPath: 'gitlab-org/design-system',
    },
    startTime: '2026-03-18T14:30:28Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 11 },
    creditsUsed: 1534,
    project: {
      id: 'gid://gitlab/Project/278973',
      name: 'Monitoring Tools and Observability Platform for Large Scale Distributed Infrastructure and Cloud Services',
      webPath: '/gitlab-org/monitoring-tools',
      fullPath: 'gitlab-org/monitoring-tools',
    },
    startTime: '2026-02-05T13:12:05Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 5 },
    creditsUsed: 789,
    project: {
      id: 'gid://gitlab/Project/278974',
      name: 'Cloud Infrastructure',
      webPath: '/gitlab-org/cloud-infrastructure',
      fullPath: 'gitlab-org/cloud-infrastructure',
    },
    startTime: '2025-12-10T12:45:50Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 7 },
    creditsUsed: 1123,
    project: {
      id: 'gid://gitlab/Project/278975',
      name: 'CI/CD Pipeline',
      webPath: '/gitlab-org/cicd-pipeline',
      fullPath: 'gitlab-org/cicd-pipeline',
    },
    startTime: '2026-04-20T11:22:37Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 3 },
    creditsUsed: 412,
    project: {
      id: 'gid://gitlab/Project/278976',
      name: 'Config Service',
      webPath: '/gitlab-org/config-service',
      fullPath: 'gitlab-org/config-service',
    },
    startTime: '2026-01-22T10:15:22Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 9 },
    creditsUsed: 1345,
    project: {
      id: 'gid://gitlab/Project/278977',
      name: 'Legacy Codebase',
      webPath: '/gitlab-org/legacy-codebase',
      fullPath: 'gitlab-org/legacy-codebase',
    },
    startTime: '2026-03-15T09:40:11Z',
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
      model: 'claude-3.5-sonnet',
    },
    auditEvents: { count: 12 },
    creditsUsed: 2145,
    project: {
      id: 'gid://gitlab/Project/278978',
      name: 'Security Compliance and Regulatory Framework Management System for Financial Services and Healthcare',
      webPath: '/gitlab-org/security-compliance',
      fullPath: 'gitlab-org/security-compliance',
    },
    startTime: '2026-02-18T08:25:48Z',
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

const FILTERS = {
  name: (item, value) => item.name === value,
  startTimeAfter: (item, value) => new Date(item.startTime) >= new Date(value),
  startTimeBefore: (item, value) => new Date(item.startTime) <= new Date(value),
  projectPath: (item, value) => item.project.fullPath === value,
};

const NOT_FILTERS = {
  name: (item, value) => item.name !== value,
  projectPath: (item, value) => item.project.fullPath !== value,
};

const applyFilters = (items, filters) => {
  return items.filter((item) => {
    return Object.entries(filters).every(([key, value]) => {
      const filterFn = FILTERS[key];
      return filterFn ? filterFn(item, value) : true;
    });
  });
};

const applyNotFilters = (items, notFilters) => {
  return items.filter((item) => {
    return Object.entries(notFilters).every(([key, value]) => {
      const filterFn = NOT_FILTERS[key];
      return filterFn ? filterFn(item, value) : true;
    });
  });
};

export const resolvers = {
  Query: {
    aiDuoWorkflow: (_, { id }) => {
      return {
        id,
        __typename: 'AiDuoWorkflow',
      };
    },
    aiItems: (
      _,
      {
        after,
        before,
        first = PAGE_SIZE,
        last,
        name,
        not,
        startTimeAfter,
        startTimeBefore,
        projectPath,
      },
    ) => {
      const filters = { name, startTimeAfter, startTimeBefore, projectPath };
      const activeFilters = Object.fromEntries(
        Object.entries(filters).filter(([, value]) => value !== undefined),
      );

      let filteredItems = applyFilters(MOCK_ITEMS, activeFilters);

      if (not) {
        filteredItems = applyNotFilters(filteredItems, not);
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

resolvers.AiDuoWorkflow = {
  auditEvents: (_, { after, before, first = AUDIT_EVENTS_PAGE_SIZE, last }) => {
    const filteredEvents = MOCK_AUDIT_EVENTS;

    let startIndex = 0;
    let endIndex = filteredEvents.length;

    if (after) {
      const afterIndex = filteredEvents.findIndex((event) => event.id === after);
      if (afterIndex !== -1) {
        startIndex = afterIndex + 1;
      }
    }

    if (before) {
      const beforeIndex = filteredEvents.findIndex((event) => event.id === before);
      if (beforeIndex !== -1) {
        endIndex = beforeIndex;
      }
    }

    let slicedEvents;
    let hasNextPage;
    let hasPreviousPage;

    if (last) {
      const sliceStart = Math.max(startIndex, endIndex - last);
      slicedEvents = filteredEvents.slice(sliceStart, endIndex);
      hasNextPage = endIndex < filteredEvents.length;
      hasPreviousPage = sliceStart > 0;
    } else {
      const sliceEnd = Math.min(startIndex + first, endIndex);
      slicedEvents = filteredEvents.slice(startIndex, sliceEnd);
      hasNextPage = sliceEnd < filteredEvents.length;
      hasPreviousPage = startIndex > 0;
    }

    return {
      nodes: slicedEvents,
      pageInfo: {
        startCursor: slicedEvents[0]?.id || null,
        endCursor: slicedEvents[slicedEvents.length - 1]?.id || null,
        hasNextPage,
        hasPreviousPage,
        __typename: 'PageInfo',
      },
      __typename: 'AuditEventConnection',
    };
  },
};

export default resolvers;
