import base from 'test_fixtures/graphql/explore/analytics_dashboards/integration/get_system_dashboard.query.graphql.json';
import featureFlagDisabled from 'test_fixtures/graphql/explore/analytics_dashboards/integration/get_system_dashboard_feature_flag_disabled.query.graphql.json';
import { defineFixtureVariants } from 'ee_jest/integration/core/fixture_variant_schema';

export default defineFixtureVariants({
  query: 'getSystemDashboard',
  variants: {
    BASE: base,
    FEATURE_FLAG_DISABLED: featureFlagDisabled,
  },
});
