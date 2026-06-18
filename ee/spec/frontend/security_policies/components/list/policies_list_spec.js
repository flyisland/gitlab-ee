import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import {
  GlButton,
  GlDisclosureDropdown,
  GlEmptyState,
  GlLoadingIcon,
  GlSearchBoxByType,
  GlTabs,
} from '@gitlab/ui';
import PoliciesList from 'ee/security_policies/components/list/policies_list.vue';
import StatsBar from 'ee/security_policies/components/list/stats_bar.vue';
import BundlesList from 'ee/security_policies/components/list/bundles_list.vue';

const POLICY_WITH_YAML = {
  name: 'Scan policy',
  type: 'scan_result',
  enabled: true,
  updatedAt: '2024-01-01',
  yaml: 'name: Scan policy\nenabled: true\nrules:\n- type: scan_finding\n  scanners:\n  - sast\nactions:\n- type: require_approval\n  approvals_required: 1\n',
};

const mockPolicies = [
  POLICY_WITH_YAML,
  {
    name: 'Vulnerability severity rule',
    type: 'scan_result',
    enabled: true,
    updatedAt: '2024-01-02',
    yaml: '',
  },
  {
    name: 'Secret push protection',
    type: 'scan_execution',
    enabled: false,
    updatedAt: '2024-01-03',
    yaml: '',
  },
];

describe('PoliciesList', () => {
  let wrapper;

  const createComponent = ({ loading = false, policies = mockPolicies } = {}) => {
    wrapper = shallowMount(PoliciesList, {
      provide: {
        namespacePath: 'group/project',
        namespaceType: 'project',
        newPolicyPath: '/policies/new',
      },
      mocks: {
        $apollo: {
          queries: { securityPolicies: { loading } },
          mutate: jest.fn().mockResolvedValue({}),
        },
      },
      data() {
        return { securityPolicies: policies };
      },
    });
  };

  const findNewPolicyButton = () =>
    wrapper.findAllComponents(GlButton).wrappers.find((w) => w.attributes('variant') === 'confirm');
  const findStatsBar = () => wrapper.findComponent(StatsBar);
  const findPolicyRows = () => wrapper.findAll('[data-testid="policy-row"]');
  const findExpansionPanel = () => wrapper.find('[data-testid="policy-expansion-panel"]');
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findSearch = () => wrapper.findComponent(GlSearchBoxByType);
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findBundlesList = () => wrapper.findComponent(BundlesList);

  it('renders "Policies" heading', () => {
    createComponent();

    expect(wrapper.find('h1').text()).toBe('Policies');
  });

  it('renders tabs for Policies and Bundles', () => {
    createComponent();

    expect(findTabs().exists()).toBe(true);
  });

  it('renders StatsBar', () => {
    createComponent();

    expect(findStatsBar().exists()).toBe(true);
  });

  it('renders BundlesList in the bundles tab', () => {
    createComponent();

    expect(findBundlesList().exists()).toBe(true);
  });

  it('renders search box', () => {
    createComponent();

    expect(findSearch().exists()).toBe(true);
  });

  it('shows loading icon while fetching and hides policy rows', () => {
    createComponent({ loading: true });

    expect(findLoadingIcon().exists()).toBe(true);
    expect(findPolicyRows()).toHaveLength(0);
  });

  it('renders one row per policy', () => {
    createComponent();

    expect(findPolicyRows()).toHaveLength(mockPolicies.length);
  });

  it('emits create when confirm button is clicked', () => {
    createComponent();

    findNewPolicyButton().vm.$emit('click');

    expect(wrapper.emitted('create')).toBeDefined();
  });

  it('filters policies by search query', async () => {
    createComponent();

    const allCount = findPolicyRows().length;
    await findSearch().vm.$emit('input', 'Vulnerability');
    await nextTick();

    expect(findPolicyRows().length).toBeLessThan(allCount);
    expect(findPolicyRows()).toHaveLength(1);
  });

  it('shows empty state when search has no results', async () => {
    createComponent();

    await findSearch().vm.$emit('input', 'zzznomatches');
    await nextTick();

    expect(findPolicyRows()).toHaveLength(0);
    expect(findEmptyState().exists()).toBe(true);
  });

  it('does not show empty state when policies exist', () => {
    createComponent();

    expect(findEmptyState().exists()).toBe(false);
  });

  it('shows empty state when no policies exist', () => {
    createComponent({ policies: [] });

    expect(findEmptyState().exists()).toBe(true);
    expect(findPolicyRows()).toHaveLength(0);
  });

  describe('row expansion', () => {
    it('expansion panel is hidden by default', () => {
      createComponent();

      expect(findExpansionPanel().exists()).toBe(false);
    });

    it('clicking a row shows the expansion panel', async () => {
      createComponent();

      await findPolicyRows().at(0).trigger('click');

      expect(findExpansionPanel().exists()).toBe(true);
    });

    it('clicking an expanded row collapses it', async () => {
      createComponent();

      await findPolicyRows().at(0).trigger('click');
      await findPolicyRows().at(0).trigger('click');

      expect(findExpansionPanel().exists()).toBe(false);
    });

    it('shows rules and actions parsed from policy YAML', async () => {
      createComponent();

      await findPolicyRows().at(0).trigger('click');

      const panel = findExpansionPanel();
      expect(panel.text()).toContain('Scan Finding');
      expect(panel.text()).toContain('Require Approval');
    });

    it('emits edit when Edit button in expansion panel is clicked', async () => {
      createComponent();

      await findPolicyRows().at(0).trigger('click');

      const editButton = findExpansionPanel()
        .findAllComponents(GlButton)
        .wrappers.find((b) => b.text() === 'Edit');
      await editButton.vm.$emit('click');

      expect(wrapper.emitted('edit')).toBeDefined();
      expect(wrapper.emitted('edit')[0][0].name).toBe(POLICY_WITH_YAML.name);
    });
  });

  describe('row menu', () => {
    it('edit menu item emits edit with the policy', () => {
      createComponent();

      const dropdown = wrapper.findAllComponents(GlDisclosureDropdown).at(0);
      const editItem = dropdown.props('items')[0];

      editItem.action();

      expect(wrapper.emitted('edit')).toBeDefined();
      expect(wrapper.emitted('edit')[0][0].name).toBe(mockPolicies[0].name);
    });

    it('delete menu item calls deletePolicy', async () => {
      createComponent();

      const dropdown = wrapper.findAllComponents(GlDisclosureDropdown).at(0);
      const deleteItem = dropdown.props('items').find((item) => item.text === 'Delete');

      await deleteItem.action();

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith(
        expect.objectContaining({ variables: expect.objectContaining({ mode: 'REMOVE' }) }),
      );
    });
  });
});
