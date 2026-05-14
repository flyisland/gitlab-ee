import VueRouter from 'vue-router';
import { s__ } from '~/locale';
import OrbitConfiguration from './components/configuration_page.vue';
import GraphExplorer from './components/graph_explorer.vue';
import SchemaPage from './components/schema_page.vue';

export default function createRouter(base) {
  return new VueRouter({
    mode: 'history',
    base,
    routes: [
      {
        name: 'explorer',
        path: '/',
        component: GraphExplorer,
        meta: { getName: () => s__('Orbit|Data Explorer') },
      },
      {
        name: 'schema',
        path: '/schema',
        component: SchemaPage,
        meta: { getName: () => s__('Orbit|Schema') },
      },
      {
        name: 'configuration',
        path: '/configuration',
        component: OrbitConfiguration,
        meta: { getName: () => s__('Orbit|Configuration') },
      },
    ],
  });
}
