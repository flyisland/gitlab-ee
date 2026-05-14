<script>
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_GROUP } from '~/graphql_shared/constants';
import { PAGE_SIZE } from 'ee/ai/catalog/constants';
import AiCatalogMcpServersIndex from '../../pages/mcp_servers/ai_catalog_mcp_servers_index.vue';
import { deduplicateMcpServers, connectMcpServer } from '../../pages/mcp_servers/utils';
import namespaceMcpServersQuery from '../../graphql/queries/get_namespace_mcp_servers.query.graphql';

export default {
  name: 'GroupMcpServersIndex',
  components: {
    AiCatalogMcpServersIndex,
  },
  inject: {
    groupId: {
      default: null,
    },
  },
  apollo: {
    namespaceMcpServers: {
      query: namespaceMcpServersQuery,
      skip() {
        return !this.groupId;
      },
      variables() {
        return {
          groupId: convertToGraphQLId(TYPENAME_GROUP, this.groupId),
          ...this.paginationVariables,
        };
      },
      update: deduplicateMcpServers,
      result({ data }) {
        this.pageInfo = data?.aiCatalogConfiguredItems?.pageInfo || {};
      },
      error(error) {
        createAlert({
          message: error.message || s__('AICatalog|Could not fetch MCP servers.'),
          captureError: true,
        });
      },
    },
  },
  description: s__('AICatalog|MCP servers associated with the agents enabled in your namespace.'),
  emptyStateDescription: s__(
    'AICatalog|MCP servers associated with agents in this group appear here.',
  ),
  data() {
    return {
      namespaceMcpServers: [],
      pageInfo: {},
      paginationVariables: {
        before: null,
        after: null,
        first: PAGE_SIZE,
        last: null,
      },
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.namespaceMcpServers.loading;
    },
  },
  methods: {
    handleNextPage() {
      this.paginationVariables = {
        before: null,
        after: this.pageInfo.endCursor,
        first: PAGE_SIZE,
        last: null,
      };
    },
    handlePrevPage() {
      this.paginationVariables = {
        after: null,
        before: this.pageInfo.startCursor,
        first: null,
        last: PAGE_SIZE,
      };
    },
    handleConnect: connectMcpServer,
    handleDisconnected() {
      this.$apollo.queries.namespaceMcpServers.refetch();
    },
  },
};
</script>

<template>
  <ai-catalog-mcp-servers-index
    :mcp-servers="namespaceMcpServers"
    :page-info="pageInfo"
    :is-loading="isLoading"
    :description="$options.description"
    :empty-state-description="$options.emptyStateDescription"
    @next-page="handleNextPage"
    @prev-page="handlePrevPage"
    @connect="handleConnect"
    @disconnected="handleDisconnected"
  />
</template>
