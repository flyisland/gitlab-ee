// eslint-disable-next-line no-restricted-imports
import { s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import {
  buildComponentColorIndexMap,
  computeItemDepths,
  formatAgentDefinition,
  formatAgentFlowName,
  formatAgentFlowTitle,
  formatAgentFlowTitleWithId,
  formatAgentStatus,
  formatDate,
  getComponentLabel,
  getDelegationData,
  getMessageData,
  getNamespaceDatasetProperties,
  getNumericId,
  mergeRequestActionLabels,
  parseMergeRequestActionFilter,
  parsePipelineStatusFilter,
  pipelineStatusLabels,
} from 'ee/ai/duo_agents_platform/utils';
import {
  MESSAGE_SUB_TYPE_DELEGATION,
  MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
} from 'ee/ai/duo_agents_platform/constants';

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

    describe('when an agent definition is provided', () => {
      beforeEach(() => {
        formatAgentDefinition('software_development');
      });

      it('humanizes the provided definition', () => {
        expect(humanize).toHaveBeenCalledWith('software_development');
      });
    });

    describe('when the agent definition is undefined', () => {
      beforeEach(() => {
        formatAgentDefinition();
      });

      it('humanizes the default fallback text', () => {
        expect(humanize).toHaveBeenCalledWith('Agent flow');
      });
    });
  });

  describe('formatAgentFlowTitle', () => {
    beforeEach(() => {
      s__.mockReturnValue('Agent session');
      humanize.mockImplementation((str) => str.replace(/_/g, ' '));
    });

    it('returns the title when provided', () => {
      expect(formatAgentFlowTitle('My custom title', 'software_development')).toBe(
        'My custom title',
      );
    });

    it.each([null, undefined, ''])(
      'falls back to the formatted agent definition when title is %p',
      (title) => {
        expect(formatAgentFlowTitle(title, 'software_development')).toBe('software development');
      },
    );

    it('falls back to the default agent session label when both title and definition are absent', () => {
      expect(formatAgentFlowTitle(null, null)).toBe('Agent session');
    });
  });

  describe('formatAgentFlowTitleWithId', () => {
    beforeEach(() => {
      s__.mockReturnValue('Agent session');
      humanize.mockImplementation((str) => str.replace(/_/g, ' '));
    });

    it('returns the title when provided', () => {
      expect(formatAgentFlowTitleWithId('My custom title', 'software_development', 42)).toBe(
        'My custom title',
      );
    });

    it.each([null, undefined, ''])(
      'falls back to the formatted agent flow name when title is %p',
      (title) => {
        expect(formatAgentFlowTitleWithId(title, 'software_development', 42)).toBe(
          'software development #42',
        );
      },
    );

    it('falls back to the default agent session label when title and definition are absent', () => {
      expect(formatAgentFlowTitleWithId(null, null, 42)).toBe('Agent session #42');
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

    describe('when status is a non-empty string', () => {
      it.each([
        ['RUNNING', 'running', 'Running'],
        ['COMPLETED', 'completed', 'Completed'],
        ['Failed', 'failed', 'Failed'],
      ])('humanizes %p as %p', (input, humanizeArg, expected) => {
        const result = formatAgentStatus(input);

        expect(humanize).toHaveBeenCalledWith(humanizeArg);
        expect(result).toBe(expected);
      });
    });

    describe('when status is falsy', () => {
      it.each([null, undefined, ''])('returns the default text for %p', (input) => {
        const result = formatAgentStatus(input);

        expect(s__).toHaveBeenCalledWith('DuoAgentsPlatform|Unknown');
        expect(result).toBe('Unknown');
      });
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

  describe('getComponentLabel', () => {
    describe('when componentName is missing', () => {
      it.each([{}, null])('returns null for %p', (input) => {
        expect(getComponentLabel(input)).toBeNull();
      });
    });

    describe('when componentName is present without a subsessionId', () => {
      it('returns main-session attribution', () => {
        expect(getComponentLabel({ componentName: 'supervisor', subsessionId: null })).toEqual({
          componentName: 'supervisor',
          subsessionId: null,
          isSubagent: false,
        });
      });
    });

    describe('when componentName and subsessionId are both present', () => {
      it('returns subagent attribution', () => {
        expect(getComponentLabel({ componentName: 'developer', subsessionId: '12' })).toEqual({
          componentName: 'developer',
          subsessionId: '12',
          isSubagent: true,
        });
      });
    });
  });

  describe('getDelegationData', () => {
    describe('when toolInfo is missing', () => {
      it('returns null', () => {
        expect(getDelegationData({})).toBeNull();
      });
    });

    describe('when toolInfo is for a non-delegation tool', () => {
      it('returns null', () => {
        expect(getDelegationData({ toolInfo: { name: 'read_file', args: {} } })).toBeNull();
      });
    });

    describe('when toolInfo is a delegate_task object', () => {
      it('extracts subagent name, subsession id, and prompt', () => {
        expect(
          getDelegationData({
            toolInfo: {
              name: 'delegate_task',
              args: {
                subagent_name: 'developer',
                subsession_id: 123,
                prompt: 'Implement the parser',
              },
            },
          }),
        ).toEqual({
          subagentName: 'developer',
          subsessionId: '123',
          prompt: 'Implement the parser',
        });
      });
    });

    describe('when toolInfo is a delegate_task JSON string', () => {
      it('parses the string and extracts the delegation data', () => {
        expect(
          getDelegationData({
            toolInfo: JSON.stringify({
              name: 'delegate_task',
              args: {
                subagent_name: 'tester',
                subsession_id: 'abc-1',
                prompt: 'Add tests',
              },
            }),
          }),
        ).toEqual({
          subagentName: 'tester',
          subsessionId: 'abc-1',
          prompt: 'Add tests',
        });
      });
    });

    describe('when toolInfo is an invalid JSON string', () => {
      it('returns null', () => {
        expect(getDelegationData({ toolInfo: '{not-json' })).toBeNull();
      });
    });
  });

  describe('getMessageData', () => {
    beforeEach(() => {
      // Strip the namespace prefix the way the real s__ does, so test
      // assertions can use the plain English title.
      s__.mockImplementation((str) => str.split('|').pop());
    });

    it.each([
      ['user', { icon: 'user', title: 'User messaged agent', level: 1 }],
      ['request', { icon: 'question-o', title: 'Agent required human input', level: 1 }],
      ['unknown', { icon: 'work-item-maintenance', title: 'Action', level: 0 }],
    ])('returns correct data for %s message type', (messageType, expected) => {
      const message = { messageType };

      const result = getMessageData(message);

      expect(result).toEqual(expected);
    });

    it('returns default agent reasoning data for agent message type with no sub-type', () => {
      expect(getMessageData({ messageType: 'agent' })).toEqual({
        icon: 'tanuki-ai',
        title: 'Agent reasoning',
        level: 0,
      });
    });

    it('returns delegated-to-subagent data for delegation sub-type', () => {
      expect(
        getMessageData({ messageType: 'tool', messageSubType: MESSAGE_SUB_TYPE_DELEGATION }),
      ).toEqual({
        icon: 'arrow-down',
        title: 'Delegated to subagent',
        level: 1,
      });
    });

    it('returns returned-to-agent data for delegation_returns success', () => {
      expect(
        getMessageData({
          messageType: 'tool',
          messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
          status: 'success',
        }),
      ).toEqual({
        icon: 'arrow-up',
        title: 'Returned to agent',
        level: 1,
      });
    });

    it('returns failure data for delegation_returns failure', () => {
      expect(
        getMessageData({
          messageType: 'tool',
          messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
          status: 'failure',
        }),
      ).toEqual({
        icon: 'error',
        title: 'Subagent did not produce an answer',
        level: 1,
      });
    });

    it('returns returned-to-agent data for delegation_returns without known status', () => {
      expect(
        getMessageData({
          messageType: 'tool',
          messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
          status: 'running',
        }),
      ).toEqual({
        icon: 'arrow-up',
        title: 'Returned to agent',
        level: 1,
      });
    });

    it('returns tool data for tool message type', () => {
      const message = {
        messageType: 'tool',
        toolInfo: { name: 'read_file' },
      };

      const result = getMessageData(message);

      expect(result).toEqual({
        icon: 'eye',
        title: 'Read file',
        level: 0,
      });
    });

    it.each([
      [{}, "Message requires property 'message_type' but got {}"],
      [
        { messageType: null },
        'Message requires property \'message_type\' but got {"messageType":null}',
      ],
    ])('throws error when messageType is invalid: %p', (message, expectedError) => {
      expect(() => getMessageData(message)).toThrow(expectedError);
    });
  });

  describe('buildComponentColorIndexMap', () => {
    it('returns an empty map for an empty list', () => {
      expect(buildComponentColorIndexMap([])).toEqual({});
    });

    it('skips items without a componentName', () => {
      expect(buildComponentColorIndexMap([{}, { componentName: null }])).toEqual({});
    });

    it('assigns indexes in first-seen order', () => {
      const items = [
        { componentName: 'supervisor' },
        { componentName: 'developer' },
        { componentName: 'researcher' },
      ];

      expect(buildComponentColorIndexMap(items)).toEqual({
        supervisor: 0,
        developer: 1,
        researcher: 2,
      });
    });

    it('reuses the same index for repeated component names', () => {
      const items = [
        { componentName: 'supervisor' },
        { componentName: 'developer' },
        { componentName: 'supervisor' },
        { componentName: 'developer' },
      ];

      expect(buildComponentColorIndexMap(items)).toEqual({
        supervisor: 0,
        developer: 1,
      });
    });

    it('ignores items missing componentName while preserving order for the rest', () => {
      const items = [{ componentName: 'supervisor' }, {}, { componentName: 'developer' }];

      expect(buildComponentColorIndexMap(items)).toEqual({
        supervisor: 0,
        developer: 1,
      });
    });
  });

  describe('computeItemDepths', () => {
    const regular = { messageType: 'tool' };
    const delegation = { messageType: 'tool', messageSubType: MESSAGE_SUB_TYPE_DELEGATION };
    const returns = { messageType: 'tool', messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS };

    it('returns an empty list for no items', () => {
      expect(computeItemDepths([])).toEqual([]);
    });

    it('keeps every entry at depth 0 when there are no delegations', () => {
      expect(computeItemDepths([regular, regular, regular])).toEqual([0, 0, 0]);
    });

    it('indents entries between a delegation and its return', () => {
      // delegation row itself stays at the caller's depth; the rows in
      // between are indented; the return row matches the caller again.
      expect(computeItemDepths([regular, delegation, regular, regular, returns, regular])).toEqual([
        0, 0, 1, 1, 0, 0,
      ]);
    });

    it('supports nested delegations at increasing depth', () => {
      expect(
        computeItemDepths([delegation, delegation, regular, returns, returns, regular]),
      ).toEqual([0, 1, 2, 1, 0, 0]);
    });

    it('clamps depth at zero for an unmatched return', () => {
      expect(computeItemDepths([returns, regular, returns])).toEqual([0, 0, 0]);
    });
  });

  describe('getNumericId', () => {
    it.each([null, undefined, ''])('returns null for %p', (input) => {
      expect(getNumericId(input)).toBeNull();
    });

    it('extracts numeric id from a GraphQL global ID', () => {
      expect(getNumericId('gid://gitlab/User/42')).toBe(42);
    });

    it('returns the value as-is when it is not a GID', () => {
      expect(getNumericId('99')).toBe('99');
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

  describe('parsePipelineStatusFilter', () => {
    const buildFilter = (rules) => ({ pipeline_hooks: { rules } });

    it.each`
      name                             | input
      ${'undefined filter'}            | ${undefined}
      ${'empty filter'}                | ${{}}
      ${'scope present, no rules key'} | ${{ pipeline_hooks: {} }}
      ${'empty rules array'}           | ${buildFilter([])}
      ${'non-array rules'}             | ${{ pipeline_hooks: { rules: 'not an array' } }}
      ${'unsupported operator'}        | ${buildFilter([{ field: 'object_attributes.status', operator: 'eq', value: 'failed' }])}
      ${'unsupported field'}           | ${buildFilter([{ field: 'something.else', operator: 'in', value: ['failed'] }])}
      ${'multiple rules'}              | ${buildFilter([{ field: 'object_attributes.status', operator: 'in', value: ['failed'] }, { field: 'object_attributes.status', operator: 'in', value: ['success'] }])}
    `('returns [] for $name', ({ input }) => {
      expect(parsePipelineStatusFilter(input)).toEqual([]);
    });

    it('returns the known status values for a single representable rule', () => {
      const filter = buildFilter([
        { field: 'object_attributes.status', operator: 'in', value: ['failed', 'success'] },
      ]);

      expect(parsePipelineStatusFilter(filter)).toEqual(['failed', 'success']);
    });

    it('drops unknown status values from the rule', () => {
      const filter = buildFilter([
        {
          field: 'object_attributes.status',
          operator: 'in',
          value: ['failed', 'something_unknown'],
        },
      ]);

      expect(parsePipelineStatusFilter(filter)).toEqual(['failed']);
    });
  });

  describe('pipelineStatusLabels', () => {
    it('returns one label per configured status', () => {
      const filter = {
        pipeline_hooks: {
          rules: [
            { field: 'object_attributes.status', operator: 'in', value: ['failed', 'canceled'] },
          ],
        },
      };

      expect(pipelineStatusLabels(filter)).toHaveLength(2);
    });

    it('returns [] when filter is empty', () => {
      expect(pipelineStatusLabels({})).toEqual([]);
    });

    it('returns [] when the filter shape is not supported by the field', () => {
      const filter = {
        pipeline_hooks: {
          rules: [{ field: 'object_attributes.status', operator: 'eq', value: 'failed' }],
        },
      };

      expect(pipelineStatusLabels(filter)).toEqual([]);
    });
  });

  describe('parseMergeRequestActionFilter', () => {
    const buildFilter = (rules) => ({ merge_request: { rules } });

    it.each`
      name                             | input
      ${'undefined filter'}            | ${undefined}
      ${'empty filter'}                | ${{}}
      ${'scope present, no rules key'} | ${{ merge_request: {} }}
      ${'empty rules array'}           | ${buildFilter([])}
      ${'non-array rules'}             | ${{ merge_request: { rules: 'not an array' } }}
      ${'unsupported field'}           | ${buildFilter([{ field: 'something.else', operator: 'in', value: ['approved'] }])}
      ${'unsupported operator'}        | ${buildFilter([{ field: 'action', operator: 'eq', value: 'approved' }])}
      ${'non-array value'}             | ${buildFilter([{ field: 'action', operator: 'in', value: 'approved' }])}
    `('returns [] for $name', ({ input }) => {
      expect(parseMergeRequestActionFilter(input)).toEqual([]);
    });

    it('returns the approved action when present', () => {
      const filter = buildFilter([{ field: 'action', operator: 'in', value: ['approved'] }]);

      expect(parseMergeRequestActionFilter(filter)).toEqual(['approved']);
    });

    it('drops values outside the known action set', () => {
      const filter = buildFilter([
        { field: 'action', operator: 'in', value: ['approved', 'bogus'] },
      ]);

      expect(parseMergeRequestActionFilter(filter)).toEqual(['approved']);
    });
  });

  describe('mergeRequestActionLabels', () => {
    it('returns one label per configured action', () => {
      const filter = {
        merge_request: { rules: [{ field: 'action', operator: 'in', value: ['approved'] }] },
      };

      expect(mergeRequestActionLabels(filter)).toHaveLength(1);
    });

    it('returns [] when filter is empty', () => {
      expect(mergeRequestActionLabels({})).toEqual([]);
    });

    it('returns [] when the filter shape is not supported by the field', () => {
      const filter = {
        merge_request: { rules: [{ field: 'unknown', operator: 'in', value: ['approved'] }] },
      };

      expect(mergeRequestActionLabels(filter)).toEqual([]);
    });
  });
});
