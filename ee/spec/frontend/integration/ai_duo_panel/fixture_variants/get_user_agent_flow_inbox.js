import inboxWithCliSession from 'test_fixtures/graphql/ai_duo_panel/integration/get_user_agent_flow_inbox_with_cli_session.query.graphql.json';
import inboxBase from 'test_fixtures/graphql/ai_duo_panel/integration/get_user_agent_flow_inbox.query.graphql.json';
import { defineFixtureVariants } from 'ee_jest/integration/core/fixture_variant_schema';
import { setFixtureItemsCount } from 'ee_jest/integration/core/fixture_utils';

// The inbox has two empty states with different triggers, so it needs two empty
// variants rather than one: the decision tab shows its own copy whenever
// `needsDecision` is empty, while the shared empty state waits until neither alias
// has returned a row.
const withEmptyDecision = setFixtureItemsCount({
  fixture: inboxBase,
  lookupKey: 'needsDecision',
  itemCount: 0,
});

export default defineFixtureVariants({
  query: 'getUserAgentFlowInbox',
  variants: {
    BASE: inboxBase,
    DECISION_EMPTY: withEmptyDecision,
    BOTH_EMPTY: setFixtureItemsCount({
      fixture: withEmptyDecision,
      lookupKey: 'all',
      itemCount: 0,
    }),
    // Generated with a CLI session (`-interactive` flow version, INPUT_REQUIRED)
    // first in both aliases; see ee/spec/frontend/fixtures/ai_duo_panel_integration.rb.
    WITH_CLI_SESSION: inboxWithCliSession,
    // `needsDecision` trimmed to one page so the client-side filter applies;
    // `edges[0]` stays the INPUT_REQUIRED CLI row.
    WITH_CLI_SESSION_SINGLE_PAGE: setFixtureItemsCount({
      fixture: inboxWithCliSession,
      lookupKey: 'needsDecision',
      itemCount: 3,
    }),
  },
});
