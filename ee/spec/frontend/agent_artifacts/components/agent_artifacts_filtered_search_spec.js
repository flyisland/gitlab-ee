import { GlFilteredSearch } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentArtifactsFilteredSearch from 'ee/agent_artifacts/components/agent_artifacts_filtered_search.vue';

describe('AgentArtifactsFilteredSearch', () => {
  let wrapper;

  const createComponent = ({ provide = {} } = {}) => {
    wrapper = shallowMountExtended(AgentArtifactsFilteredSearch, {
      provide: {
        groupId: null,
        ...provide,
      },
    });
  };

  const findFilteredSearch = () => wrapper.findComponent(GlFilteredSearch);

  beforeEach(() => {
    createComponent();
  });

  it('renders GlFilteredSearch component', () => {
    expect(findFilteredSearch().exists()).toBe(true);
  });

  describe('available tokens', () => {
    const tokenTypes = () =>
      findFilteredSearch()
        .props('availableTokens')
        .map((token) => token.type);

    it('shows only the two date tokens in project mode', () => {
      createComponent({ provide: { projectFullPath: 'g/p' } });

      expect(tokenTypes()).toEqual(['startTimeAfter', 'startTimeBefore']);
    });

    it('shows the project token in group mode', () => {
      createComponent({ provide: { groupId: 'gid://gitlab/Group/1' } });

      expect(tokenTypes()).toEqual(['startTimeAfter', 'startTimeBefore', 'projectPath']);
    });
  });

  describe('handleSubmit', () => {
    it('emits filter event with variables for = operator', () => {
      findFilteredSearch().vm.$emit('input', [
        {
          type: 'name',
          value: {
            data: 'False Positive Detection',
            operator: '=',
          },
        },
      ]);

      findFilteredSearch().vm.$emit('submit');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({
        name: 'False Positive Detection',
      });
    });

    it('emits filter event with not variables for != operator', () => {
      findFilteredSearch().vm.$emit('input', [
        {
          type: 'name',
          value: {
            data: 'Code Review Assistant',
            operator: '!=',
          },
        },
      ]);

      findFilteredSearch().vm.$emit('submit');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({
        not: {
          name: 'Code Review Assistant',
        },
      });
    });

    it('handles multiple filters with mixed operators', () => {
      findFilteredSearch().vm.$emit('input', [
        {
          type: 'name',
          value: {
            data: 'Agent 1',
            operator: '=',
          },
        },
        {
          type: 'status',
          value: {
            data: 'active',
            operator: '!=',
          },
        },
      ]);

      findFilteredSearch().vm.$emit('submit');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({
        name: 'Agent 1',
        not: {
          status: 'active',
        },
      });
    });

    it('ignores filters without value data', () => {
      findFilteredSearch().vm.$emit('input', [
        {
          type: 'name',
          value: {},
        },
        {
          type: 'status',
          value: {
            data: 'active',
            operator: '=',
          },
        },
      ]);

      findFilteredSearch().vm.$emit('submit');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({
        status: 'active',
      });
    });

    it('emits empty object when no filters applied', () => {
      findFilteredSearch().vm.$emit('input', []);

      findFilteredSearch().vm.$emit('submit');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({});
    });
  });

  describe('when clearing filter', () => {
    it('emits filter event with empty object when clear is clicked', () => {
      findFilteredSearch().vm.$emit('clear');

      expect(wrapper.emitted('filter')).toHaveLength(1);
      expect(wrapper.emitted('filter')[0][0]).toEqual({});
    });
  });
});
