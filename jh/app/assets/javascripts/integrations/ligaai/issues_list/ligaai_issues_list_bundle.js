import ligaaiLogo from '@jihu-fe/svgs/dist/illustrations/jh/logos/ligaai.svg?raw';
import externalIssuesListFactory from 'ee/external_issues_list';
import { s__ } from '~/locale';
import getIssuesQuery from './graphql/queries/get_ligaai_issues.query.graphql';
import ligaaiIssues from './graphql/resolvers/ligaai_issues';

export default externalIssuesListFactory({
  externalIssuesQueryResolver: ligaaiIssues,
  provides: {
    getIssuesQuery,
    externalIssuesLogo: ligaaiLogo,
    externalIssueTrackerName: 'LigaAI',
    searchInputPlaceholderText: s__('JH|Integrations|Search LigaAI issues'),
    recentSearchesStorageKey: 'ligaai_issues',
    createNewIssueText: s__('JH|Integrations|Create new issue in LigaAI'),
    logoContainerClass: 'logo-container',
    emptyStateNoIssueText: s__(
      'JH|Integrations|LigaAI issues display here when you create issues in your project in LigaAI.',
    ),
  },
});
