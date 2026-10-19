export const ADMIN_CACHE_CONFIG = {
  typePolicies: {
    Query: {
      fields: {
        knowledgeGraphExcludedNamespaces: {
          keyArgs: false,
          merge(existing, incoming, { args }) {
            if (!existing || !args?.after) return incoming;
            if (!incoming) return existing;

            return { ...incoming, nodes: [...existing.nodes, ...incoming.nodes] };
          },
        },
      },
    },
  },
};
