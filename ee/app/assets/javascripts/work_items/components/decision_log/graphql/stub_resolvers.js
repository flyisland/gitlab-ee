// The decision log is read from the server, but nothing writes to it over GraphQL yet. These
// client-only mutations stand in for the write path, and edit the records the real query cached.
// TODO: Drop this file once the decision log mutations are exposed over GraphQL.
// https://gitlab.com/gitlab-org/gitlab/-/work_items/615863
export const decisionLogStubResolvers = {
  Query: {},
  Mutation: {
    workItemDecisionUpdate: (_, { input }) => ({
      __typename: 'LocalWorkItemDecisionUpdatePayload',
      decision: {
        __typename: 'WorkItemDecision',
        id: input.id,
        title: input.title,
        description: input.description,
        resolutionRationale: input.resolutionRationale,
        noteUrl: input.noteUrl,
        resolvedBy: {
          __typename: 'UserCore',
          ...input.resolvedBy,
        },
      },
      errors: [],
    }),
    // Evicting the record drops the dangling reference from the cached list automatically, so
    // this resolver does not need to know the shape of the query that fetched the list.
    workItemDecisionDelete: (_, { input: { id } }, { cache }) => {
      cache.evict({ id: cache.identify({ __typename: 'WorkItemDecision', id }) });
      cache.gc();

      return { __typename: 'LocalWorkItemDecisionDeletePayload', errors: [] };
    },
  },
};
