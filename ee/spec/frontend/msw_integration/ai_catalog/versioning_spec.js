import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlToast } from '@gitlab/ui';
import createDefaultClient from '~/lib/graphql';
import {
  assignRouter,
  fullMount,
  getText,
  findButtonByText,
  waitForAssertion,
} from 'jest/msw_integration/test_helpers';
import { createRouter } from 'ee/ai/catalog/router';
import AiCatalogItem from 'ee/ai/catalog/pages/ai_catalog_item.vue';
import {
  AI_CATALOG_ITEM_LABELS,
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
} from 'ee/ai/catalog/constants';
import {
  agentResponse,
  agentPinnedToLatestResponse,
  flowResponse,
  flowPinnedToLatestResponse,
  resetAiCatalogCache,
} from 'ee_jest/msw_integration/handlers/ai_catalog';

const createAiCatalogRouter = () => createRouter('/');

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

Vue.use(VueApollo);
Vue.use(GlToast);

const PROJECT_PROVIDE = {
  namespace: 'gitlab-org/gitlab',
  isGlobalNamespace: false,
  isProjectNamespace: true,
  isGroupNamespace: false,
  projectId: '1',
  rootGroupId: null,
  groupId: null,
  aiImpactDashboardEnabled: false,
  instanceBetaFeaturesEnabled: false,
  showLegalDisclaimer: false,
};

const UPDATE_ALERT_TEXT = 'A new version is available';

function mountAiCatalogComponent({ itemType, component, routePath, apolloProvider }) {
  const router = assignRouter(createAiCatalogRouter, { routerPath: routePath });

  fullMount(component, {
    router,
    apolloProvider,
    provide: PROJECT_PROVIDE,
    propsData: { itemType },
  });
}

const VERSIONING_CONFIGS = [
  {
    itemType: AI_CATALOG_TYPE_AGENT,
    component: AiCatalogItem,
    fixtureResponse: agentResponse,
    pinnedToLatestResponse: agentPinnedToLatestResponse,
    routePath: '/agents/1',
  },
  {
    itemType: AI_CATALOG_TYPE_FLOW,
    component: AiCatalogItem,
    fixtureResponse: flowResponse,
    pinnedToLatestResponse: flowPinnedToLatestResponse,
    routePath: '/flows/1',
  },
];

describe.each(VERSIONING_CONFIGS)(
  '$itemType version pinning',
  ({ itemType, component, fixtureResponse, pinnedToLatestResponse, routePath }) => {
    let apolloProvider;

    beforeEach(() => {
      window.gon = { ...window.gon, features: { aiCatalogFlows: true } };
    });

    afterEach(() => {
      apolloProvider?.defaultClient?.stop();
    });

    const mount = () => {
      apolloProvider = new VueApollo({ defaultClient: createDefaultClient() });
      mountAiCatalogComponent({ itemType, component, routePath, apolloProvider });
    };

    describe('when update is available', () => {
      const itemLabel = AI_CATALOG_ITEM_LABELS[itemType];
      const item = fixtureResponse.data.aiCatalogItem;
      const itemName = item.name;
      const pinnedVersion = item.configurationForProject.pinnedItemVersion.humanVersionName;
      const latestVersion = item.latestVersion.humanVersionName;

      beforeEach(() => {
        resetAiCatalogCache();
      });

      describe('Version display', () => {
        it(`shows ${itemLabel} name and pinned version by default`, async () => {
          mount();

          await waitForAssertion(() => {
            const text = getText(document.body);
            expect(text).toContain(itemName);
            expect(text).toContain(pinnedVersion);
          });
        });

        it('shows version alert when update is available', async () => {
          mount();

          await waitForAssertion(() => {
            expect(getText(document.body)).toContain(itemName);
          });

          expect(getText(document.body)).toContain(UPDATE_ALERT_TEXT);
        });
      });

      describe('View latest version', () => {
        it('clicking "View latest version" switches to latest version content', async () => {
          mount();

          await waitForAssertion(() => {
            expect(getText(document.body)).toContain(pinnedVersion);
          });

          findButtonByText('View latest version').click();

          await waitForAssertion(() => {
            expect(getText(document.body)).toContain(latestVersion);
          });
        });
      });

      describe('Update to latest version', () => {
        it('updates content after clicking "Update"', async () => {
          mount();

          await waitForAssertion(() => {
            expect(getText(document.body)).toContain(pinnedVersion);
          });

          findButtonByText('View latest version').click();

          await waitForAssertion(() => {
            expect(getText(document.body)).toContain(latestVersion);
          });

          findButtonByText(`Update to ${latestVersion}`).click();

          await waitForAssertion(() => {
            expect(getText(document.body)).not.toContain(UPDATE_ALERT_TEXT);
          });

          expect(getText(document.body)).toContain(latestVersion);
        });
      });
    });

    describe('when no update is available', () => {
      const latestVersion =
        pinnedToLatestResponse.data.aiCatalogItem.latestVersion.humanVersionName;

      beforeEach(() => {
        const cacheKey = itemType === AI_CATALOG_TYPE_AGENT ? 'agent' : 'flow';
        resetAiCatalogCache({ [cacheKey]: pinnedToLatestResponse });
      });

      it('does not show version alert when pinned to latest', async () => {
        mount();

        await waitForAssertion(() => {
          expect(getText(document.body)).toContain(latestVersion);
        });

        expect(getText(document.body)).not.toContain(UPDATE_ALERT_TEXT);
      });
    });
  },
);
