import Vue from 'vue';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import OrbitApp from './components/app.vue';
import createRouter from './router';

Vue.use(VueApollo);
Vue.use(VueRouter);

export default function initOrbit() {
  const el = document.getElementById('js-orbit-app');

  if (!el) return null;

  const { routerBase, configureMode, adminConfigurationPath, agenticChatAvailable } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const router = createRouter(routerBase);

  return new Vue({
    el,
    name: 'OrbitRoot',
    apolloProvider,
    router,
    render(h) {
      return h(OrbitApp, {
        props: {
          configureMode,
          adminConfigurationPath,
          agenticChatAvailable: parseBoolean(agenticChatAvailable),
        },
      });
    },
  });
}
