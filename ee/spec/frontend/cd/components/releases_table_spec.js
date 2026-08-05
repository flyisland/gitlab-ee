import { GlTableLite } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import ReleasesTable from 'ee/cd/components/releases_table.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

describe('ReleasesTable', () => {
  let wrapper;

  const releases = [
    {
      id: 'gid://gitlab/Cd::VersionSet/1',
      name: 'v1_1_0',
      createdAt: '2024-06-01T00:00:00Z',
      rollouts: { nodes: [{ state: 'IN_PROGRESS' }] },
      versionSetEntries: {
        count: 2,
        nodes: [
          { service: { id: 'gid://gitlab/Cd::Service/10' } },
          { service: { id: 'gid://gitlab/Cd::Service/10' } },
          { service: { id: 'gid://gitlab/Cd::Service/20' } },
        ],
      },
    },
    {
      id: 'gid://gitlab/Cd::VersionSet/2',
      name: 'v1_0_0',
      createdAt: '2024-05-01T00:00:00Z',
      rollouts: { nodes: [{ state: 'COMPLETED' }] },
      versionSetEntries: {
        count: 1,
        nodes: [{ service: { id: 'gid://gitlab/Cd::Service/10' } }],
      },
    },
  ];

  const findTable = () => wrapper.findComponent(GlTableLite);
  const findRows = () => wrapper.findAll('tbody tr');
  const findHeaders = () => wrapper.findAll('thead th');
  const findRowCells = (rowIndex) => findRows().at(rowIndex).findAll('td');

  const createComponent = (props = {}) => {
    wrapper = mountExtended(ReleasesTable, {
      propsData: { releases, ...props },
    });
  };

  describe('collapsed (default)', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the version and status columns', () => {
      expect(findHeaders().wrappers.map((h) => h.text())).toEqual(['Version', 'Status']);
    });

    it('renders a row per release showing its version name', () => {
      expect(findRows()).toHaveLength(releases.length);
      expect(findRows().at(0).text()).toContain('v1_1_0');
      expect(findRows().at(1).text()).toContain('v1_0_0');
    });

    it('emits select with the release when its row is clicked', () => {
      findTable().vm.$emit('row-clicked', releases[0]);

      expect(wrapper.emitted('select')).toEqual([[releases[0]]]);
    });
  });

  describe('expanded (full)', () => {
    beforeEach(() => {
      createComponent({ full: true });
    });

    it('renders the version, status, services, and created columns', () => {
      expect(findHeaders().wrappers.map((h) => h.text())).toEqual([
        'Version',
        'Status',
        'Services',
        'Created',
      ]);
    });

    it('shows the count of services in the release', () => {
      expect(findRowCells(0).at(2).text()).toBe('2');
      expect(findRowCells(1).at(2).text()).toBe('1');
    });

    it('shows the created date via TimeAgo', () => {
      expect(wrapper.findComponent(TimeAgo).props('time')).toBe('2024-06-01T00:00:00Z');
    });
  });

  describe('status column', () => {
    it.each([
      ['PENDING', 'Pending'],
      ['IN_PROGRESS', 'In progress'],
      ['PAUSED', 'Paused'],
      ['COMPLETED', 'Available'],
      ['FAILED', 'Failed'],
      ['CANCELLED', 'Cancelled'],
    ])('renders the %s rollout state as "%s"', (state, label) => {
      createComponent({
        releases: [
          { id: 'gid://gitlab/Cd::VersionSet/9', name: 'v', rollouts: { nodes: [{ state }] } },
        ],
      });

      expect(findRowCells(0).at(1).text()).toBe(label);
    });
  });

  describe('with a selected release', () => {
    beforeEach(() => {
      createComponent({ selectedId: 'gid://gitlab/Cd::VersionSet/1' });
    });

    it('highlights the selected release row only', () => {
      expect(findRows().at(0).classes()).toContain('gl-bg-purple-50');
      expect(findRows().at(1).classes()).not.toContain('gl-bg-purple-50');
    });
  });

  describe('with an open release', () => {
    beforeEach(() => {
      createComponent({ openId: 'gid://gitlab/Cd::VersionSet/1' });
    });

    it('highlights the open release row only', () => {
      expect(findRows().at(0).classes()).toContain('gl-bg-blue-50');
      expect(findRows().at(1).classes()).not.toContain('gl-bg-blue-50');
    });
  });

  describe('with no releases', () => {
    beforeEach(() => {
      createComponent({ releases: [] });
    });

    it('renders no rows', () => {
      expect(findTable().exists()).toBe(true);
      expect(findRows()).toHaveLength(0);
    });
  });
});
