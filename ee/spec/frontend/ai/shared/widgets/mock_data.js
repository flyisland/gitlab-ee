import { INITIATOR_USER } from 'ee/ai/shared/widgets/constants';

export const mockAgentActorLinePropsWithoutAgentName = {
  sessionId: 'gid://gitlab/Ai::DuoWorkflows::Workflow/42',
  canViewSession: true,
  initiatorType: INITIATOR_USER,
  initiator: { label: '@nokafor', webPath: '/nokafor' },
};

export const mockAgentActorLineProps = {
  ...mockAgentActorLinePropsWithoutAgentName,
  agentName: 'Developer Agent',
  withAgentName: true,
};

export const mockAgentPresence = {
  agentName: 'Developer Agent',
  agentCatalogWebPath: '/-/ai/catalog/agents/3',
  sessionId: 'gid://gitlab/Ai::DuoWorkflows::Workflow/42',
  initiatorType: INITIATOR_USER,
  initiator: { label: '@nokafor', webPath: '/nokafor' },
  userPermissions: { readDuoWorkflow: true },
};
