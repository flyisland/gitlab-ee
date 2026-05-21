// eslint-disable-next-line no-restricted-imports
import { s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import {
  formatAgentDefinition,
  formatAgentFlowName,
  formatAgentStatus,
  getNamespaceDatasetProperties,
  formatDate,
} from 'ee/ai/duo_agents_platform/utils';

// Mock the dependencies
jest.mock('~/locale');
jest.mock('~/lib/utils/text_utility');
jest.mock('~/lib/utils/axios_utils', () => ({
  __esModule: true,
  default: {
    patch: jest.fn(),
  },
}));
jest.mock('~/lib/utils/datetime/locale_dateformat', () => ({
  localeDateFormat: {
    asDate: {
      format: jest.fn((date) => {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        return date.toLocaleDateString('en-US', options);
      }),
    },
  },
}));
jest.mock('~/api/api_utils', () => ({
  buildApiUrl: (url) => url.replace(':version', 'v4'),
}));

describe('duo_agents_platform utils', () => {
  describe('formatAgentDefinition', () => {
    beforeEach(() => {
      s__.mockReturnValue('Agent flow');
      humanize.mockImplementation((str) => str.replace(/_/g, ' '));
    });

    it('returns humanized agent definition when provided', () => {
      formatAgentDefinition('software_development');

      expect(humanize).toHaveBeenCalledWith('software_development');
    });

    it('returns default text when agent definition is undefined', () => {
      formatAgentDefinition();

      expect(humanize).toHaveBeenCalledWith('Agent flow');
    });
  });

  describe('formatAgentFlowName', () => {
    beforeEach(() => {
      s__.mockReturnValue('Agent flow');
    });

    it('formats agent flow name with definition and id', () => {
      const agentDefinition = 'software_development';
      const id = 123;

      const results = formatAgentFlowName(agentDefinition, id);

      expect(humanize).toHaveBeenCalledWith('software_development');
      expect(results).toBe('software development #123');
    });

    it('formats agent flow name with default definition when null', () => {
      const id = 456;

      const result = formatAgentFlowName(null, id);

      expect(result).toBe('Agent flow #456');
    });

    it('formats agent flow name with string id', () => {
      const agentDefinition = 'convert_to_ci';
      const id = '789';

      const result = formatAgentFlowName(agentDefinition, id);

      expect(result).toBe('convert to ci #789');
    });
  });

  describe('formatAgentStatus', () => {
    beforeEach(() => {
      s__.mockReturnValue('Unknown');
      humanize.mockImplementation((str) => str.charAt(0).toUpperCase() + str.slice(1));
    });

    it('returns humanized status when provided', () => {
      const status = 'RUNNING';

      const result = formatAgentStatus(status);

      expect(humanize).toHaveBeenCalledWith('running');
      expect(result).toBe('Running');
    });

    it('returns humanized status for completed status', () => {
      const status = 'COMPLETED';

      const result = formatAgentStatus(status);

      expect(humanize).toHaveBeenCalledWith('completed');
      expect(result).toBe('Completed');
    });

    it('returns default text when status is null', () => {
      const result = formatAgentStatus(null);

      expect(s__).toHaveBeenCalledWith('DuoAgentsPlatform|Unknown');
      expect(result).toBe('Unknown');
    });

    it('returns default text when status is undefined', () => {
      const result = formatAgentStatus(undefined);

      expect(s__).toHaveBeenCalledWith('DuoAgentsPlatform|Unknown');
      expect(result).toBe('Unknown');
    });

    it('returns default text when status is empty string', () => {
      const result = formatAgentStatus('');

      expect(s__).toHaveBeenCalledWith('DuoAgentsPlatform|Unknown');
      expect(result).toBe('Unknown');
    });

    it('handles mixed case status', () => {
      const status = 'Failed';

      const result = formatAgentStatus(status);

      expect(humanize).toHaveBeenCalledWith('failed');
      expect(result).toBe('Failed');
    });
  });

  describe('getNamespaceDatasetProperties', () => {
    it('returns object with specified properties from dataset', () => {
      const dataset = {
        prop1: 'value1',
        prop2: 'value2',
        prop3: 'value3',
        unwanted: 'unwanted',
      };
      const properties = ['prop1', 'prop3'];

      const result = getNamespaceDatasetProperties(dataset, properties);

      expect(result).toEqual({
        prop1: 'value1',
        prop3: 'value3',
      });
    });

    it('returns empty object when no properties specified', () => {
      const dataset = { prop1: 'value1' };
      const properties = [];

      const result = getNamespaceDatasetProperties(dataset, properties);

      expect(result).toEqual({});
    });

    it('handles undefined properties in dataset', () => {
      const dataset = { prop1: 'value1' };
      const properties = ['prop1', 'nonexistent'];

      const result = getNamespaceDatasetProperties(dataset, properties);

      expect(result).toEqual({
        prop1: 'value1',
        nonexistent: undefined,
      });
    });
  });

  describe('formatDate', () => {
    it('formats a valid ISO date string', () => {
      const result = formatDate('2024-01-01T00:00:00Z');

      expect(result).toBe('Jan 1, 2024');
    });

    it.each([null, undefined, ''])('returns empty string for %p', (input) => {
      expect(formatDate(input)).toBe('');
    });
  });
});
