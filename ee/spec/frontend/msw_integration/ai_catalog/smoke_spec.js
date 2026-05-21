import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlToast } from '@gitlab/ui';
import { waitFor } from '@testing-library/dom';
import createDefaultClient from '~/lib/graphql';
import { assignRouter, fullMount, getText, findByTestId } from 'jest/msw_integration/test_helpers';
import { createRouter } from 'ee/ai/catalog/router';
import AiCatalogItem from 'ee/ai/catalog/pages/ai_catalog_item.vue';
import { AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_FLOW } from 'ee/ai/catalog/constants';
import { agentResponse, flowResponse } from 'ee_jest/msw_integration/handlers/ai_catalog';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

Vue.use(VueApollo);
Vue.use(GlToast);

const createAiCatalogRouter = () => {
  return createRouter('/');
};

const EXPLORE_PROVIDE = {
  namespace: 'explore',
  isGlobalNamespace: true,
  isProjectNamespace: false,
  isGroupNamespace: false,
  projectId: null,
  rootGroupId: null,
  groupId: null,
  aiImpactDashboardEnabled: false,
  instanceBetaFeaturesEnabled: false,
  showLegalDisclaimer: false,
};

const UPDATE_ALERT_TEXT = 'A new version is available';

const fixtureAgentName = agentResponse.data.aiCatalogItem.name;
const fixtureAgentLatestVersionName =
  agentResponse.data.aiCatalogItem.latestVersion.humanVersionName;
const fixtureFlowName = flowResponse.data.aiCatalogItem.name;
const fixtureFlowLatestVersionName = flowResponse.data.aiCatalogItem.latestVersion.humanVersionName;

describe('AI Catalog MSW smoke test', () => {
  let apolloProvider;

  const createApolloProvider = () => {
    apolloProvider = new VueApollo({
      defaultClient: createDefaultClient(),
    });
    return apolloProvider;
  };

  beforeEach(async () => {
    window.gon = {
      ...window.gon,
      features: { aiCatalogFlows: true },
    };
    await apolloProvider?.defaultClient?.cache?.reset();
  });

  describe('Agent show page', () => {
    beforeEach(() => {
      const router = assignRouter(createAiCatalogRouter, { routerPath: '/agents/1' });

      fullMount(AiCatalogItem, {
        router,
        apolloProvider: createApolloProvider(),
        provide: EXPLORE_PROVIDE,
        propsData: {
          itemType: AI_CATALOG_TYPE_AGENT,
        },
      });
    });

    it('renders the agent show page with fixture data from MSW', async () => {
      await waitFor(() => {
        expect(getText(document.body)).toContain(fixtureAgentName);
      });
    });

    it('passes aiCatalogItem and version props correctly to the item show component', async () => {
      await waitFor(() => {
        // aiCatalogItem: item name renders in the page heading
        expect(getText(document.body)).toContain(fixtureAgentName);

        // version.activeVersionKey = VERSION_LATEST: latest version name shown in metadata
        expect(getText(findByTestId('metadata-version'))).toContain(fixtureAgentLatestVersionName);

        // version.isUpdateAvailable = false: no update alert shown in explore context
        expect(getText(document.body)).not.toContain(UPDATE_ALERT_TEXT);
      });
    });
  });

  describe('Flow show page', () => {
    beforeEach(() => {
      const router = assignRouter(createAiCatalogRouter, { routerPath: '/flows/1' });

      fullMount(AiCatalogItem, {
        router,
        apolloProvider: createApolloProvider(),
        provide: EXPLORE_PROVIDE,
        propsData: {
          itemType: AI_CATALOG_TYPE_FLOW,
        },
      });
    });

    it('renders the flow show page with fixture data from MSW', async () => {
      await waitFor(() => {
        expect(getText(document.body)).toContain(fixtureFlowName);
      });
    });

    it('passes aiCatalogItem and version props correctly to the item show component', async () => {
      await waitFor(() => {
        // aiCatalogItem: item name renders in the page heading
        expect(getText(document.body)).toContain(fixtureFlowName);

        // version.activeVersionKey = VERSION_LATEST: latest version name shown in metadata
        expect(getText(findByTestId('metadata-version'))).toContain(fixtureFlowLatestVersionName);

        // version.isUpdateAvailable = false: no update alert shown in explore context
        expect(getText(document.body)).not.toContain(UPDATE_ALERT_TEXT);
      });
    });
  });
});
