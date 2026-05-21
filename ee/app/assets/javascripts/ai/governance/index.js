import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { resolvers as agentArtifactsResolvers } from 'ee/agent_artifacts/graphql/resolvers';
import { resolvers as aiToolRulesResolvers } from './graphql/resolvers';
import GovernanceApp from './components/governance_app.vue';

Vue.use(VueApollo);

export const initGovernanceApp = () => {
  const el = document.querySelector('#js-governance');

  if (!el) {
    return false;
  }

  const { groupId, groupFullPath } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient({
      ...agentArtifactsResolvers,
      Query: {
        ...agentArtifactsResolvers.Query,
        ...aiToolRulesResolvers.Query,
      },
      Mutation: {
        ...aiToolRulesResolvers.Mutation,
      },
    }),
  });

  return new Vue({
    el,
    name: 'GovernanceRoot',
    apolloProvider,
    provide: {
      groupId,
      groupFullPath,
      projectId: null,
      glFeatures: gon.features || {},
    },
    render(createElement) {
      return createElement(GovernanceApp);
    },
  });
};
