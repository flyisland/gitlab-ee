import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import AgentArtifactsApp from './components/agent_artifacts_app.vue';
import { resolvers } from './graphql/resolvers';

Vue.use(VueApollo);

export const initAgentArtifactsApp = () => {
  const el = document.querySelector('#js-agent-artifacts');

  if (!el) {
    return false;
  }

  const { groupId, projectId } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(resolvers),
  });

  return new Vue({
    el,
    name: 'AgentArtifactsRoot',
    apolloProvider,
    provide: {
      groupId,
      projectId,
    },
    render(createElement) {
      return createElement(AgentArtifactsApp);
    },
  });
};
