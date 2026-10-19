import Vue from 'vue';
import { fetch, Request, Response, Headers } from '@whatwg-node/fetch';
import { configure } from '@testing-library/vue';
import GlLicensedFeaturesPlugin from '~/vue_shared/gl_licensed_features_plugin';
import GlFeatureFlagsPlugin from '~/vue_shared/gl_feature_flags_plugin';
import GlAbilitiesPlugin from '~/vue_shared/gl_abilities_plugin';
import Translate from '~/vue_shared/translate';
import {
  clearMissingOperations,
  missingOperations,
  resetCapturedRequests,
} from './core/operation_helpers';
import { server } from './server';
import { setupRouter, setUserSession } from './helpers/setup_utils';
import { resetAllVariants } from './core/fixture_variant_schema';
import { baseMetadata } from './core/constants';
import * as testHelpers from './helpers/test_helpers';
import * as workItemsTestHelpers from './work_items/test_helpers';

jest.mock('~/actioncable_consumer', () => ({
  __esModule: true,
  default: {
    subscriptions: {
      create: jest.fn(() => ({
        unsubscribe: jest.fn(),
        perform: jest.fn(),
      })),
    },
  },
}));

global.fetch = fetch;
global.Request = Request;
global.Response = Response;
global.Headers = Headers;
global.metadata = baseMetadata;

// Mirrors `commons/vue`, which real pages load but neither jest lane does. Without these,
// `glFeatures` injects as `{}` and every flag-gated path takes its "off" branch.
Vue.use(GlLicensedFeaturesPlugin);
Vue.use(GlFeatureFlagsPlugin);
Vue.use(GlAbilitiesPlugin);
Vue.use(Translate);

// Import all test helpers as global utilities
Object.assign(global, testHelpers);
Object.assign(global, workItemsTestHelpers);

// Under CI load a starved worker can blow @testing-library's 1000ms waitFor
// default; 3s gives headroom and stays under the suite's testTimeout.
configure({ asyncUtilTimeout: 3000 });

let flashContainer;

beforeAll(() => {
  server.listen({ onUnhandledRequest: 'warn' });
});

beforeEach(async () => {
  // MSW 2 streams response bodies across event-loop ticks. When a test finishes
  // mid-stream, the response arrives in the next test's fresh cache. cache.reset()
  // does not cancel in-flight requests, so Apollo's deduplication reuses the stale
  // response. clearMountedApolloStores() cancels these fetches. We do this in
  // beforeEach so the previous test's components are already destroyed.
  await testHelpers.clearMountedApolloStores();

  const { router } = global.metadata;
  if (router) {
    await setupRouter(router);
  }
  // Do not reset `gon.features` / `gon.licensed_features` here: `shared_test_setup.js`
  // rebuilds `window.gon` before every test, so `setFeatureFlags` and
  // `setLicensedFeatures` already start from a clean base.
  // We default to logged in user for test. In scenarios where
  // we want logged out, consumers can call `setUserSession(false)`
  // in a describe block.
  setUserSession(true);
  // Always set in production (lib/gitlab/gon_helper.rb); REST clients build URLs from it.
  window.gon.api_version = 'v4';

  // createAlert is a no-op without this container, which the page layout provides.
  flashContainer = document.createElement('div');
  flashContainer.className = 'flash-container';
  document.body.appendChild(flashContainer);
});

afterEach(() => {
  // The rest of the reset runs in `finally`, so a failing teardown cannot leak the
  // handlers, fixture variants and session into every later test in the file.
  try {
    testHelpers.unmountBootstrappedApps();
  } finally {
    flashContainer?.remove();
    flashContainer = null;
    server.resetHandlers();
    global.metadata = baseMetadata;
    resetCapturedRequests();
    resetAllVariants();
    setUserSession(true);
  }
});

afterAll(() => {
  // `server.close()` must run even if the missing-handler warning throws (the
  // ConsoleWatcher turns it into a synchronous throw). Otherwise the MSW server
  // leaks, the worker never exits, and Jest hangs until --forceExit masks the run.
  try {
    if (missingOperations.size > 0) {
      // eslint-disable-next-line no-console
      console.warn(
        `Test suite is missing graphql handlers for operations: ${Array.from(missingOperations, (el) => `\n - ${el}`)}\n\nSee https://docs.gitlab.com/ee/development/testing_guide/frontend_testing/#write-feature-handlers`,
      );
      clearMissingOperations();
    }
  } finally {
    server.close();
  }
});
