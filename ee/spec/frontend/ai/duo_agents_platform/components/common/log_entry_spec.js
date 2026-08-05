import { GlButton, GlCollapse } from '@gitlab/ui';
import { MessageToolKvSection } from '@gitlab/duo-ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import LogEntry from 'ee/ai/duo_agents_platform/components/common/log_entry.vue';
import AgentFlowUserApproval from 'ee/ai/duo_agents_platform/components/common/agent_flow_user_approval.vue';
import TodoChecklist from 'ee/ai/duo_agents_platform/components/common/todo_checklist.vue';
import ComponentLabel from 'ee/ai/duo_agents_platform/components/common/component_label.vue';
import SubagentBadge from 'ee/ai/duo_agents_platform/components/common/subagent_badge.vue';
import { captureException } from '~/sentry/sentry_browser_wrapper';
import NonGfmMarkdown from '~/vue_shared/components/markdown/non_gfm_markdown.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import {
  mockItems,
  mockItemsWithFilepath,
  mockItemsWithToolResponse,
  mockItemsWithTodos,
  mockItemsWithComponentAttribution,
} from './mock';

jest.mock('~/sentry/sentry_browser_wrapper');

describe('LogEntry', () => {
  let wrapper;

  const findTitle = () => wrapper.findByTestId('log-entry-title');
  const findTimestamp = () => wrapper.findComponent(TimeAgoTooltip);
  const findMarkdown = () => wrapper.findComponent(NonGfmMarkdown);
  const findPlainText = () => wrapper.findByTestId('log-entry-plain-text');
  const findCollapseButton = () => wrapper.findComponent(GlButton);
  const findCollapse = () => wrapper.findComponent(GlCollapse);
  const findAllToolKvSections = () => wrapper.findAllComponents(MessageToolKvSection);
  const findToolResponseSection = () => wrapper.findByTestId('log-entry-tool-response');
  const findCodeElement = () => wrapper.findByTestId('log-entry-file-path');
  const findAgentFlowUserApproval = () => wrapper.findComponent(AgentFlowUserApproval);
  const findCustomRenderer = () => wrapper.findByTestId('log-entry-custom-renderer');
  const findTodoChecklist = () => wrapper.findComponent(TodoChecklist);
  const findComponentLabel = () => wrapper.findComponent(ComponentLabel);
  const findSubagentBadge = () => wrapper.findComponent(SubagentBadge);
  const findAttributedLine = () => wrapper.findByTestId('log-entry-attributed-line');
  const findToolName = () => wrapper.findByTestId('log-entry-tool-name');
  const findInlineContent = () => wrapper.findByTestId('log-entry-inline-content');

  const createWrapper = (props = {}) => {
    return shallowMountExtended(LogEntry, {
      propsData: {
        item: mockItems[0],
        index: 1,
        last: false,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
        ...props,
      },
    });
  };

  describe('title rendering', () => {
    describe('when index is 0', () => {
      it('renders "Session triggered" title', () => {
        wrapper = createWrapper({ index: 0 });
        expect(findTitle().text()).toBe('Session triggered');
      });
    });

    describe('when index is greater than 0', () => {
      it('renders title in DOM', () => {
        wrapper = createWrapper({ index: 1 });
        expect(findTitle().exists()).toBe(true);
      });
    });
  });

  describe('timestamp rendering', () => {
    it('renders TimeAgoTooltip component with correct props', () => {
      wrapper = createWrapper();
      const timestamp = findTimestamp();

      expect(timestamp.exists()).toBe(true);
      expect(timestamp.props('time')).toBe(mockItems[0].timestamp);
      expect(timestamp.props('cssClass')).toBe('gl-text-subtle gl-text-sm');
    });
  });

  describe('content rendering', () => {
    describe('when isMarkdown is true (messageType !== "user" and index > 0)', () => {
      it('renders markdown element', () => {
        wrapper = createWrapper({
          item: { ...mockItems[0], messageType: 'agent' },
          index: 1,
        });

        expect(findMarkdown().exists()).toBe(true);
      });
    });

    describe('when isMarkdown is false (messageType === "user" or index === 0)', () => {
      it('renders plain text for user messages', () => {
        wrapper = createWrapper({
          item: { ...mockItems[0], messageType: 'user' },
          index: 1,
        });

        expect(findMarkdown().exists()).toBe(false);
        expect(findPlainText().text()).toBe(mockItems[0].content);
      });

      it('renders plain text when index is 0', () => {
        wrapper = createWrapper({
          item: { ...mockItems[0], messageType: 'agent' },
          index: 0,
        });

        expect(findMarkdown().exists()).toBe(false);
        expect(findPlainText().text()).toBe(mockItems[0].content);
      });
    });
  });

  describe('component attribution', () => {
    describe('when componentName is present', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithComponentAttribution[0],
          index: 1,
        });
      });

      it('renders ComponentLabel with component attribution props', () => {
        expect(findComponentLabel().exists()).toBe(true);
        expect(findComponentLabel().props('componentName')).toBe('supervisor');
      });

      it('renders inline content line with tool name and content', () => {
        expect(findAttributedLine().exists()).toBe(true);
        expect(findToolName().text()).toBe('read_file');
        expect(findInlineContent().text()).toBe(mockItemsWithComponentAttribution[0].content);
      });

      it('truncates long inline content for attributed entries', () => {
        wrapper = createWrapper({
          item: {
            ...mockItemsWithComponentAttribution[0],
            content: 'x'.repeat(200),
          },
          index: 1,
        });

        expect(findInlineContent().text()).toBe(`${'x'.repeat(139)}…`);
      });

      it('does not render markdown for attributed entries', () => {
        expect(findMarkdown().exists()).toBe(false);
      });
    });

    describe('when componentName is null', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithComponentAttribution[2],
          index: 1,
        });
      });

      it('does not render ComponentLabel and preserves existing rendering', () => {
        expect(findComponentLabel().exists()).toBe(false);
        expect(findAttributedLine().exists()).toBe(false);
        expect(findMarkdown().exists()).toBe(true);
      });
    });

    describe('when messageType is "request" and componentName is present', () => {
      const requestContent = 'Please review the following release notes and approve or reject.';

      beforeEach(() => {
        wrapper = createWrapper({
          item: {
            ...mockItemsWithComponentAttribution[0],
            messageType: 'request',
            content: requestContent,
          },
          index: 1,
        });
      });

      it('renders ComponentLabel for attribution', () => {
        expect(findComponentLabel().exists()).toBe(true);
        expect(findComponentLabel().props('componentName')).toBe('supervisor');
      });

      it('renders the attributed line without inline content', () => {
        expect(findAttributedLine().exists()).toBe(true);
        expect(findInlineContent().exists()).toBe(false);
      });

      it('renders full content via NonGfmMarkdown without truncation', () => {
        expect(findMarkdown().exists()).toBe(true);
        expect(findMarkdown().props('markdown')).toBe(requestContent);
      });
    });

    describe('when messageType is "agent" and componentName is present', () => {
      const agentContent = 'x'.repeat(300);

      beforeEach(() => {
        wrapper = createWrapper({
          item: {
            ...mockItemsWithComponentAttribution[0],
            messageType: 'agent',
            content: agentContent,
          },
          index: 1,
        });
      });

      it('renders ComponentLabel for attribution', () => {
        expect(findComponentLabel().exists()).toBe(true);
      });

      it('renders full content via NonGfmMarkdown without truncation', () => {
        expect(findMarkdown().exists()).toBe(true);
        expect(findMarkdown().props('markdown')).toBe(agentContent);
      });

      it('does not render truncated inline content', () => {
        expect(findInlineContent().exists()).toBe(false);
      });
    });

    describe('when entry belongs to a subagent', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithComponentAttribution[1],
          index: 1,
        });
      });

      it('renders SubagentBadge inside tool details collapse', () => {
        expect(findSubagentBadge().exists()).toBe(true);
        expect(findSubagentBadge().props('componentName')).toBe('developer');
        expect(findSubagentBadge().props('subsessionId')).toBe('789');
      });
    });
  });

  describe('tool info functionality', () => {
    describe('when item has toolInfo', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithFilepath[0],
        });
      });

      it('renders collapse button', () => {
        expect(findCollapseButton().exists()).toBe(true);
      });

      it('collapse button has chevron-right icon initially', () => {
        expect(findCollapseButton().props('icon')).toBe('chevron-right');
      });

      it('renders GlCollapse component', () => {
        expect(findCollapse().exists()).toBe(true);
      });

      it('collapse is initially hidden', () => {
        expect(findCollapse().props('visible')).toBe(false);
      });

      it('renders MessageToolKvSection with correct props', () => {
        const kvSection = findAllToolKvSections().at(0);
        expect(kvSection.exists()).toBe(true);
        expect(kvSection.props('title')).toBe('Request');
        expect(kvSection.props('value')).toEqual({
          file_path: 'src/components/example.vue',
        });
      });

      it('toggles collapse visibility when button is clicked', async () => {
        expect(findCollapseButton().props('icon')).toBe('chevron-right');
        expect(findCollapse().props('visible')).toBe(false);

        await findCollapseButton().vm.$emit('click');

        expect(findCollapseButton().props('icon')).toBe('chevron-down');
        expect(findCollapse().props('visible')).toBe(true);
      });

      it('toggles collapse back when button is clicked again', async () => {
        await findCollapseButton().vm.$emit('click');
        expect(findCollapse().props('visible')).toBe(true);

        await findCollapseButton().vm.$emit('click');

        expect(findCollapseButton().props('icon')).toBe('chevron-right');
        expect(findCollapse().props('visible')).toBe(false);
      });
    });

    describe('when item does not have toolInfo', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItems[0],
        });
      });

      it('does not render collapse button', () => {
        expect(findCollapseButton().exists()).toBe(false);
      });

      it('does not render GlCollapse', () => {
        expect(findCollapse().exists()).toBe(false);
      });
    });

    describe('when toolInfo includes tool_response', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithToolResponse[0],
        });
      });

      it('renders two MessageToolKvSection components', () => {
        expect(findAllToolKvSections()).toHaveLength(2);
      });

      it('renders the Request section with toolInfo.args', () => {
        const requestSection = findAllToolKvSections().at(0);
        expect(requestSection.props('title')).toBe('Request');
        expect(requestSection.props('value')).toEqual(
          JSON.parse(mockItemsWithToolResponse[0].toolInfo).args,
        );
      });

      it('renders the Response section with toolInfo.tool_response', () => {
        const responseSection = findAllToolKvSections().at(1);
        expect(responseSection.props('title')).toBe('Response');
        expect(responseSection.props('value')).toEqual(
          JSON.parse(mockItemsWithToolResponse[0].toolInfo).tool_response,
        );
      });

      it('renders the Response section element', () => {
        expect(findToolResponseSection().exists()).toBe(true);
      });
    });

    describe('when toolInfo does not include tool_response', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithFilepath[0],
        });
      });

      it('renders only one MessageToolKvSection (Request only)', () => {
        expect(findAllToolKvSections()).toHaveLength(1);
      });

      it('does not render the Response section element', () => {
        expect(findToolResponseSection().exists()).toBe(false);
      });
    });

    describe('when toolInfo has invalid JSON', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: {
            ...mockItems[0],
            toolInfo: 'invalid json{',
          },
        });
      });

      it('calls captureException', () => {
        expect(captureException).toHaveBeenCalled();
      });

      it('does not render collapse button', () => {
        expect(findCollapseButton().exists()).toBe(false);
      });
    });
  });

  describe('file path rendering', () => {
    describe('when item has file_path in toolInfo', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItemsWithFilepath[0],
        });
      });

      it('renders code element with file path', () => {
        const codeElement = findCodeElement();
        expect(codeElement.exists()).toBe(true);
        expect(codeElement.text()).toBe('src/components/example.vue');
      });
    });

    describe('when item does not have file_path in toolInfo', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: mockItems[0],
        });
      });

      it('does not render code element', () => {
        expect(findCodeElement().exists()).toBe(false);
      });
    });
  });

  describe('when tool has a registered custom renderer', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        item: mockItemsWithTodos[0],
        index: 1,
      });
    });

    it('renders the custom renderer component inside collapse', () => {
      expect(findCustomRenderer().exists()).toBe(true);
    });

    it('renders TodoChecklist as the custom renderer', () => {
      expect(findTodoChecklist().exists()).toBe(true);
    });

    it('passes parsed toolInfo object as tool-info prop to custom renderer', () => {
      const parsed = JSON.parse(mockItemsWithTodos[0].toolInfo);
      expect(findTodoChecklist().props('toolInfo')).toEqual(parsed);
    });

    it('passes flowFinished as false to TodoChecklist', () => {
      expect(findTodoChecklist().props('flowFinished')).toBe(false);
    });

    describe('when the item is marked todoFinished', () => {
      beforeEach(() => {
        wrapper = createWrapper({
          item: { ...mockItemsWithTodos[0], todoFinished: true },
          index: 1,
        });
      });

      it('passes flowFinished as true to TodoChecklist', () => {
        expect(findTodoChecklist().props('flowFinished')).toBe(true);
      });
    });

    it('does not render MessageToolKvSection', () => {
      expect(wrapper.findAllComponents(MessageToolKvSection)).toHaveLength(0);
    });

    it('still renders content text above collapse via NonGfmMarkdown', () => {
      expect(findMarkdown().exists()).toBe(true);
      expect(findMarkdown().props('markdown')).toBe(mockItemsWithTodos[0].content);
    });

    it('renders collapse button', () => {
      expect(findCollapseButton().exists()).toBe(true);
    });

    it('toggles collapse visibility when button is clicked', async () => {
      expect(findCollapse().props('visible')).toBe(false);

      await findCollapseButton().vm.$emit('click');

      expect(findCollapse().props('visible')).toBe(true);
    });
  });

  describe('agent flow user approval', () => {
    describe.each`
      messageType  | canResumeWorkflow | canUpdateWorkflow | last     | shouldRender | description
      ${'request'} | ${true}           | ${true}           | ${true}  | ${true}      | ${'when messageType is "request", canResumeWorkflow is true, canUpdateWorkflow is true, and last is true'}
      ${'user'}    | ${true}           | ${true}           | ${true}  | ${false}     | ${'when messageType is not "request"'}
      ${'request'} | ${false}          | ${true}           | ${true}  | ${false}     | ${'when canResumeWorkflow is false'}
      ${'request'} | ${true}           | ${false}          | ${true}  | ${false}     | ${'when canUpdateWorkflow is false'}
      ${'request'} | ${true}           | ${true}           | ${false} | ${false}     | ${'when last is false'}
    `(
      '$description',
      ({ messageType, canResumeWorkflow, canUpdateWorkflow, last, shouldRender }) => {
        beforeEach(() => {
          wrapper = createWrapper({
            item: { ...mockItems[0], messageType },
            canResumeWorkflow,
            canUpdateWorkflow,
            last,
          });
        });

        it(`${shouldRender ? 'renders' : 'does not render'} AgentFlowUserApproval component`, () => {
          expect(findAgentFlowUserApproval().exists()).toBe(shouldRender);
        });
      },
    );
  });
});
