import createMockApollo from 'helpers/mock_apollo_helper';
import { decisionLogStubResolvers } from 'ee/work_items/components/decision_log/graphql/stub_resolvers';
import decisionLogQuery from 'ee/work_items/components/decision_log/graphql/decision_log.query.graphql';
import deleteDecisionMutation from 'ee/work_items/components/decision_log/graphql/delete_decision.mutation.graphql';
import updateDecisionMutation from 'ee/work_items/components/decision_log/graphql/update_decision.mutation.graphql';
import {
  decisionLogResponse,
  mockFullPath,
  mockThreadAuthor,
  mockWorkItemId,
  mockWorkItemIid,
} from '../mock_data';

const variables = { fullPath: mockFullPath, iid: mockWorkItemIid };

// The decider comes from a query in the app, so the user is already cached when the form saves.
const editedFields = {
  title: 'Scope SCIM into the MVP',
  description: 'Rewritten context.',
  resolutionRationale: 'Rewritten rationale.',
  noteUrl: 'https://gitlab.example.com/acme/web/-/work_items/7#note_1',
  resolvedBy: {
    id: mockThreadAuthor.id,
    name: mockThreadAuthor.name,
    avatarUrl: mockThreadAuthor.avatarUrl,
  },
};

describe('decision log stub resolvers', () => {
  let client;
  let original;
  let sibling;

  const readDecisions = () =>
    client.readQuery({ query: decisionLogQuery, variables })?.namespace?.workItem?.features
      ?.decisionLog?.decisions?.nodes ?? [];
  const findDecision = (id) => readDecisions().find((decision) => decision.id === id);

  beforeEach(async () => {
    client = createMockApollo(
      [[decisionLogQuery, jest.fn().mockResolvedValue(decisionLogResponse())]],
      decisionLogStubResolvers,
    ).defaultClient;

    await client.query({ query: decisionLogQuery, variables });
    [original, sibling] = readDecisions();
  });

  describe('workItemDecisionUpdate', () => {
    beforeEach(async () => {
      await client.mutate({
        mutation: updateDecisionMutation,
        variables: { input: { id: original.id, ...editedFields } },
      });
    });

    it('changes the decision in the log', () => {
      expect(findDecision(original.id)).toMatchObject(editedFields);
    });

    it('leaves what the form cannot change alone', () => {
      expect(findDecision(original.id)).toMatchObject({
        resolvedAt: original.resolvedAt,
        options: original.options,
      });
    });

    it('leaves the other decisions alone', () => {
      expect(readDecisions()).toHaveLength(3);
      expect(findDecision(sibling.id)).toEqual(sibling);
    });
  });

  describe('workItemDecisionDelete', () => {
    beforeEach(async () => {
      await client.mutate({
        mutation: deleteDecisionMutation,
        variables: { input: { id: original.id, workItemId: mockWorkItemId } },
      });
    });

    it('drops the decision from the log', () => {
      expect(findDecision(original.id)).toBeUndefined();
    });

    it('keeps the rest of the log', () => {
      expect(readDecisions()).toHaveLength(2);
    });
  });

  describe('when the decision was never fetched', () => {
    let result;

    beforeEach(async () => {
      result = await client.mutate({
        mutation: deleteDecisionMutation,
        variables: {
          input: { id: 'gid://gitlab/WorkItems::Decision/404', workItemId: mockWorkItemId },
        },
      });
    });

    it('reports no error', () => {
      expect(result.data.workItemDecisionDelete.errors).toEqual([]);
    });

    it('leaves the log that was fetched alone', () => {
      expect(readDecisions()).toHaveLength(3);
    });
  });
});
