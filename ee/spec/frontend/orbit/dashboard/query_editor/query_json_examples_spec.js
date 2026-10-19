import { GlAccordion, GlAccordionItem, GlAlert, GlLink } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import QueryJsonExamples from 'ee/orbit/dashboard/query_editor/query_json_examples.vue';

describe('QueryJsonExamples', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mountExtended(QueryJsonExamples);
  };

  const findExamples = () => wrapper.findAllComponents(GlAccordionItem).wrappers;

  beforeEach(() => {
    createComponent();
  });

  it('says that GQL replaces the JSON format and links to the JSON reference', () => {
    expect(wrapper.findComponent(GlAlert).text()).toBe(
      'The JSON query format is going away. GQL replaces it soon.',
    );
    expect(wrapper.findComponent(GlLink).attributes('href')).toBe(
      'https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/blob/main/docs/design-documents/querying/intermediary_llm_query_language.md',
    );
  });

  it('keeps one example open at a time', () => {
    expect(wrapper.findComponent(GlAccordion).props('autoCollapse')).toBe(true);
  });

  it('shows one collapsible example for each query type, with only the first open', () => {
    expect(
      findExamples().map((example) => [example.props('title'), example.props('visible')]),
    ).toEqual([
      ['Traversal: entities and their relationships', true],
      ['Aggregation: count by a group', false],
      ['Neighbors: everything linked to one node', false],
      ['Path finding: shortest path', false],
    ]);
  });

  it('formats each example as indented JSON and copies the same text', () => {
    const codes = findExamples().map((example) => example.find('pre').text());

    expect(codes[1]).toBe(`{
  "query_type": "aggregation",
  "nodes": [
    {
      "id": "v",
      "entity": "Vulnerability",
      "filters": {
        "report_type": "sast"
      }
    }
  ],
  "group_by": [
    "v.severity"
  ],
  "aggregations": [
    {
      "count": "v",
      "as": "total"
    }
  ],
  "limit": 10
}`);
    expect(
      findExamples().map((example) => example.findComponent(ClipboardButton).props('text')),
    ).toEqual(codes);
  });
});
