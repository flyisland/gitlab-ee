import { mountExtended } from 'helpers/vue_test_utils_helper';
import SummarySection from 'ee/agent_artifacts/components/summary_section.vue';
import { formatDate } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { LONG_DATE_FORMAT_WITH_TZ } from '~/vue_shared/constants';

const EM_DASH = '—';

const ROW_TESTIDS = [
  'summary-row-author-id',
  'summary-row-author-name',
  'summary-row-target-type',
  'summary-row-target-details',
  'summary-row-event-type',
  'summary-row-ip-address',
  'summary-row-timestamp',
];

describe('SummarySection', () => {
  let wrapper;

  const mockEvent = {
    author: {
      id: 'gid://gitlab/User/42',
      name: 'Scott Hampton',
    },
    eventName: 'tool_execution',
    ipAddress: '127.0.0.1',
    createdAt: '2024-01-01T12:00:00Z',
  };

  const targetType = 'Ai::DuoWorkflows::Workflow';
  const targetDetails = 'false_positive_detection/v1 session 1908';

  const createComponent = ({ event = mockEvent, props = {} } = {}) => {
    wrapper = mountExtended(SummarySection, {
      propsData: {
        event,
        targetType,
        targetDetails,
        ...props,
      },
    });
  };

  const findRow = (testid) => wrapper.findByTestId(testid);
  const rowValue = (testid) => findRow(testid).findAll('span').at(1).text();

  describe('rows', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders all summary rows', () => {
      ROW_TESTIDS.forEach((testid) => {
        expect(findRow(testid).exists()).toBe(true);
      });
    });

    it('does not render any entity rows', () => {
      expect(findRow('summary-row-entity-id').exists()).toBe(false);
      expect(findRow('summary-row-entity-type').exists()).toBe(false);
      expect(findRow('summary-row-entity-path').exists()).toBe(false);
    });
  });

  describe('with a fully populated event', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the author id from the GraphQL id', () => {
      expect(rowValue('summary-row-author-id')).toBe(
        String(getIdFromGraphQLId(mockEvent.author.id)),
      );
    });

    it('renders the author name', () => {
      expect(rowValue('summary-row-author-name')).toBe('Scott Hampton');
    });

    it('renders the target rows from the passed props', () => {
      expect(rowValue('summary-row-target-type')).toBe(targetType);
      expect(rowValue('summary-row-target-details')).toBe(targetDetails);
    });

    it('renders the event type', () => {
      expect(rowValue('summary-row-event-type')).toBe('tool_execution');
    });

    it('renders the ip address', () => {
      expect(rowValue('summary-row-ip-address')).toBe('127.0.0.1');
    });

    it('renders the formatted timestamp', () => {
      expect(rowValue('summary-row-timestamp')).toBe(
        formatDate(mockEvent.createdAt, LONG_DATE_FORMAT_WITH_TZ),
      );
    });
  });

  describe('with a blank target', () => {
    beforeEach(() => {
      createComponent({ props: { targetType: '', targetDetails: '' } });
    });

    it('renders an em-dash rather than a blank row', () => {
      expect(rowValue('summary-row-target-type')).toBe(EM_DASH);
      expect(rowValue('summary-row-target-details')).toBe(EM_DASH);
    });
  });

  describe('with a missing author', () => {
    beforeEach(() => {
      createComponent({ event: { ...mockEvent, author: null } });
    });

    it('renders an em-dash for the author rows', () => {
      expect(rowValue('summary-row-author-id')).toBe(EM_DASH);
      expect(rowValue('summary-row-author-name')).toBe(EM_DASH);
    });
  });

  describe('with a missing timestamp', () => {
    beforeEach(() => {
      createComponent({ event: { ...mockEvent, createdAt: null } });
    });

    it('renders an em-dash for the timestamp', () => {
      expect(rowValue('summary-row-timestamp')).toBe(EM_DASH);
    });
  });
});
