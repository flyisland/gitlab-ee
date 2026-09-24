<script>
import { GlBreadcrumb } from '@gitlab/ui';
import { s__ } from '~/locale';
import { truncate } from '~/lib/utils/text_utility';
import { breadcrumbState, itemKeyFromRoute } from './breadcrumb_state';
import { AI_CATALOG_INDEX_ROUTE } from './constants';

// Item names allow up to 255 characters, which the breadcrumb bar cannot fit.
const MAX_ITEM_NAME_LENGTH = 25;

export default {
  name: 'AiCatalogBreadcrumbs',
  components: {
    GlBreadcrumb,
  },
  inject: {
    includeNamespaceBreadcrumbs: {
      default: false,
    },
    rootRouteName: {
      default: AI_CATALOG_INDEX_ROUTE,
    },
  },
  props: {
    staticBreadcrumbs: {
      required: true,
      type: Array,
    },
    allStaticBreadcrumbs: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    crumbs() {
      // Get the first matched items. Iterate over each of them and make them a breadcrumb item
      // only if they have a meta field with text
      const itemKey = itemKeyFromRoute(this.$route);
      const fetchedName =
        itemKey && breadcrumbState.itemKey === itemKey ? breadcrumbState.name : '';
      const itemParam = fetchedName && truncate(fetchedName, MAX_ITEM_NAME_LENGTH);
      const matchedRoutes = (this.$route?.matched || [])
        .map((route) => {
          const useRouteId = Boolean(route.meta?.useId);
          const text = useRouteId && itemParam ? String(itemParam) : route.meta?.text;

          // Skip routes without text
          if (!text) return null;

          let to;
          if (route.name) {
            // Route has a name, so we can link directly to it
            to = { name: route.name, params: this.$route.params };
          } else if (route.meta?.indexRoute) {
            // An unnamed route that has an indexRoute specified -- use the indexRoute
            to = { name: route.meta.indexRoute, params: this.$route.params };
          } else {
            // Fallback
            to = { path: route.path };
          }

          return { text, to };
        })
        .filter(Boolean);

      return [...this.staticCrumbs, ...matchedRoutes];
    },
    namespaceCrumbs() {
      return this.includeNamespaceBreadcrumbs ? this.allStaticBreadcrumbs : this.staticBreadcrumbs;
    },
    staticCrumbs() {
      return [
        ...this.namespaceCrumbs,
        {
          text: s__('AICatalog|AI Catalog'),
          to: { name: this.rootRouteName },
        },
      ];
    },
  },
};
</script>
<template>
  <gl-breadcrumb :items="crumbs" :auto-resize="false" />
</template>
