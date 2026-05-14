import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { concatPagination } from '@apollo/client/utilities';
import createDefaultClient from '~/lib/graphql';
import { initSimpleApp } from '~/helpers/init_simple_app_helper';
import MavenRegistryDetailsApp from 'ee/packages_and_registries/virtual_registries/pages/common/registry/show.vue';
import i18n from 'ee/packages_and_registries/virtual_registries/pages/maven/i18n';
import getRegistryQuery from 'ee/packages_and_registries/virtual_registries/graphql/queries/get_maven_registry.query.graphql';
import getRegistryUpstreamsQuery from 'ee/packages_and_registries/virtual_registries/graphql/queries/get_maven_virtual_registry_upstreams.query.graphql';
import createUpstreamMutation from 'ee/packages_and_registries/virtual_registries/graphql/mutations/create_maven_upstream.mutation.graphql';
import getUpstreamsSelectQuery from 'ee/packages_and_registries/virtual_registries/graphql/queries/get_maven_upstreams_select.query.graphql';
import getUpstreamsCountQuery from 'ee/packages_and_registries/virtual_registries/graphql/queries/get_maven_upstreams_count.query.graphql';
import getUpstreamSummaryQuery from 'ee/packages_and_registries/virtual_registries/graphql/queries/get_maven_upstream_summary.query.graphql';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(
    {},
    {
      cacheConfig: {
        typePolicies: {
          Group: {
            fields: {
              virtualRegistriesPackagesMavenUpstreams: {
                merge: true,
                keyArgs: ['groupPath', 'upstreamName'],
              },
            },
          },
          MavenUpstreamConnection: {
            fields: {
              nodes: concatPagination(),
            },
          },
        },
      },
    },
  ),
});

initSimpleApp('#js-vue-maven-registry-details', MavenRegistryDetailsApp, {
  withApolloProvider: apolloProvider,
  name: 'MavenRegistryDetails',
  additionalProvide: {
    ids: {
      baseRegistry: 'VirtualRegistries::Packages::Maven::Registry',
    },
    i18n,
    getRegistryQuery,
    createUpstreamMutation,
    getRegistryUpstreamsQuery,
    getUpstreamsCountQuery,
    getUpstreamsSelectQuery,
    getUpstreamSummaryQuery,
    isMavenUpstream: true,
  },
});
