import {
  featureHandlers as ceFeatureHandlers,
  restEndpoints as ceRestEndpoints,
} from 'jest/msw_integration/handlers';
import { handleAiCatalogOperation, aiCatalogRestEndpoints } from './handlers/ai_catalog';

export { buildHandlers } from 'jest/msw_integration/handlers';

export const featureHandlers = [...ceFeatureHandlers, handleAiCatalogOperation];
export const restEndpoints = [...ceRestEndpoints, ...aiCatalogRestEndpoints];
