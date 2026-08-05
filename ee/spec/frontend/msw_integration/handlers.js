import {
  featureHandlers as ceFeatureHandlers,
  restEndpoints as ceRestEndpoints,
} from 'jest/msw_integration/handlers';
import { handleAiCatalogOperation, aiCatalogRestEndpoints } from './handlers/ai_catalog';
import { handleAiDuoPanelEEOperation } from './handlers/ai_duo_panel';
import { handleAiAgenticChatOperation } from './handlers/ai_agentic_chat';

export { buildHandlers } from 'jest/msw_integration/handlers';

export const featureHandlers = [
  ...ceFeatureHandlers,
  handleAiCatalogOperation,
  // Agentic-chat handler runs before the duo-panel handler so the agentic chat
  // integration tests get the archived/active workflow fixtures from
  // `ai_agentic_chat.js` instead of the duo-panel fallback for shared
  // GraphQL operations like `getUserWorkflows`.
  handleAiAgenticChatOperation,
  handleAiDuoPanelEEOperation,
];
export const restEndpoints = [...ceRestEndpoints, ...aiCatalogRestEndpoints];
