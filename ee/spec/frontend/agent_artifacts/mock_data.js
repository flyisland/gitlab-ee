export const mockAiItems = {
  count: 2,
  nodes: [
    {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
      name: 'False Positive Detection',
      session: {
        id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
        webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions',
      },
      auditEvents: { count: 4 },
      creditsUsed: 1247,
      project: {
        id: 'gid://gitlab/Project/278964',
        name: 'Security Scanner',
        webPath: '/gitlab-org/security-scanner',
      },
      startTime: '2026-03-05T22:14:17Z',
      latestCheckpoint: {
        duoMessages: [
          { content: 'Starting Flow: 228929' },
          {
            content: 'Build review context for merge request !228929 in project 278964',
          },
          {
            content: 'Post Duo Code Review to merge request !228929 in project 278964',
          },
        ],
      },
    },
    {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2',
      name: 'Code Review Assistant',
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
          { content: 'Starting Flow: 228931' },
          {
            content: 'Build review context for merge request !228931 in project 278965',
          },
          {
            content: 'Post Duo Code Review to merge request !228931 in project 278965',
          },
        ],
      },
    },
  ],
  pageInfo: {
    startCursor: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
    endCursor: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2',
    hasNextPage: true,
    hasPreviousPage: false,
  },
};
