import { shallowMount } from '@vue/test-utils';
import {
  OPERATORS_IS,
  OPERATORS_IS_NOT,
} from '~/vue_shared/components/filtered_search_bar/constants';
import ProjectDependenciesFilteredSearch from 'ee/dependencies/components/filtered_search/project_dependencies_filtered_search.vue';
import DependenciesFilteredSearch from 'ee/dependencies/components/filtered_search/dependencies_filtered_search.vue';
import ComponentToken from 'ee/dependencies/components/filtered_search/tokens/component_token.vue';
import VersionToken from 'ee/dependencies/components/filtered_search/tokens/version_token.vue';
import ActivityToken from 'ee/dependencies/components/filtered_search/tokens/activity_token.vue';
import MalwareToken from 'ee/security_dashboard/components/shared/filtered_search/tokens/malware_token.vue';

describe('ProjectDependenciesFilteredSearch', () => {
  let wrapper;

  const createComponent = ({ provide = {} } = {}) => {
    wrapper = shallowMount(ProjectDependenciesFilteredSearch, {
      provide: {
        glFeatures: {
          maliciousPackageDetection: true,
        },
        ...provide,
      },
    });
  };

  const findDependenciesFilteredSearch = () => wrapper.findComponent(DependenciesFilteredSearch);

  beforeEach(() => {
    createComponent();
  });

  it('sets the filtered search id', () => {
    expect(findDependenciesFilteredSearch().props('filteredSearchId')).toBe(
      'project-level-filtered-search',
    );
  });

  it.each`
    tokenTitle     | tokenConfig
    ${'Component'} | ${{ title: 'Component', type: 'component_names', multiSelect: true, token: ComponentToken, operators: OPERATORS_IS }}
    ${'Version'}   | ${{ title: 'Version', type: 'component_versions', multiSelect: true, token: VersionToken, operators: OPERATORS_IS_NOT }}
    ${'Activity'}  | ${{ title: 'Activity', type: 'component_activity', multiSelect: false, token: ActivityToken, operators: OPERATORS_IS }}
    ${'Malware'}   | ${{ title: 'Malware', type: 'malware', multiSelect: false, token: MalwareToken, operators: OPERATORS_IS }}
  `('contains a "$tokenTitle" search token', ({ tokenConfig }) => {
    expect(findDependenciesFilteredSearch().props('tokens')).toMatchObject(
      expect.arrayContaining([
        expect.objectContaining({
          ...tokenConfig,
        }),
      ]),
    );
  });

  it('does not include the malware token when maliciousPackageDetection feature flag is disabled', () => {
    createComponent({ provide: { glFeatures: { maliciousPackageDetection: false } } });

    const tokenTypes = findDependenciesFilteredSearch()
      .props('tokens')
      .map((t) => t.type);

    expect(tokenTypes).toMatchObject([
      'component_names',
      'component_versions',
      'component_activity',
    ]);
  });
});
