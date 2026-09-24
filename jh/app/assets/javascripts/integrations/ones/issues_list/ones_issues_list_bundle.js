import externalIssuesListFactory from 'ee/external_issues_list';
import onesLogo from 'jh_images/logos/ones.svg?raw';
import { s__ } from '~/locale';
import getIssuesQuery from './graphql/queries/get_ones_issues.query.graphql';
import onesIssues from './graphql/resolvers/ones_issues';

export default externalIssuesListFactory({
  externalIssuesQueryResolver: onesIssues,
  provides: {
    getIssuesQuery,
    externalIssuesLogo: onesLogo,
    // This like below is passed to <gl-sprintf :message="%authorName in {}" />
    // So we don't translate it since this should be a proper noun
    // eslint-disable-next-line @gitlab/require-i18n-strings
    externalIssueTrackerName: 'Ones',
    searchInputPlaceholderText: s__('JH|Integrations|Search ONES issues'),
    recentSearchesStorageKey: 'ones_issues',
    createNewIssueText: s__('JH|Integrations|Create new issue in ONES'),
    logoContainerClass: 'logo-container',
    emptyStateNoIssueText: s__(
      'JH|Integrations|ONES issues display here when you create issues in your project in ONES.',
    ),
  },
});
