import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import AgentArtifactsApp from './components/agent_artifacts_app.vue';

Vue.use(VueApollo);

export const initAgentArtifactsApp = () => {
  const el = document.querySelector('#js-agent-artifacts');

  if (!el) {
    return false;
  }

  const { groupId, projectId, groupFullPath, projectFullPath } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el,
    name: 'AgentArtifactsRoot',
    apolloProvider,
    provide: {
      groupId,
      projectId,
      groupFullPath,
      projectFullPath: projectFullPath ?? null,
    },
    render(createElement) {
      return createElement(AgentArtifactsApp);
    },
  });
};
