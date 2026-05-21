<script>
import OpenAgenticChatButton from 'ee/ai/shared/widgets/open_agentic_chat_button.vue';
import getAccessTokenPermissions from '~/personal_access_tokens/graphql/get_access_token_permissions.query.graphql';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_USER } from '~/graphql_shared/constants';
import { s__, __ } from '~/locale';

const AGENT = { name: __('Permissions Assistant') };
const TOOL_NAME = 'update_form_permissions';
const WELCOME_MESSAGE = s__(
  'AccessTokens|I am your fine-grained permissions assistant. I can help you choose the right permissions for your access token.',
);
const PREDEFINED_PROMPTS = [
  s__('AccessTokens|I want to read and write to repositories via the API.'),
  s__('AccessTokens|I need to manage CI/CD pipelines and read job logs.'),
  s__('AccessTokens|I want to automate issue and merge request management.'),
  s__('AccessTokens|I need read-only access to projects and groups.'),
];

export default {
  name: 'AskDapPermissions',
  components: {
    OpenAgenticChatButton,
  },
  inject: ['agenticAvailable'],
  emits: ['permissions-selected', 'permissions-cleared'],
  data() {
    return {
      permissions: [],
      permissionsError: false,
    };
  },
  computed: {
    isLoaded() {
      return this.permissions.length > 0;
    },
    resourceId() {
      return convertToGraphQLId(TYPENAME_USER, window.gon?.current_user_id);
    },
    buttonOptions() {
      return {
        disabled: this.permissionsError || !this.isLoaded,
        title: this.permissionsError ? this.$options.i18n.permissionsLoadError : undefined,
      };
    },
  },
  apollo: {
    permissions: {
      query: getAccessTokenPermissions,
      update(data) {
        return data?.accessTokenPermissions || [];
      },
      error() {
        this.permissionsError = true;
      },
    },
  },
  i18n: {
    buttonLabel: s__('AccessTokens|Add permissions with Duo'),
    permissionsLoadError: __('Unable to load permissions'),
  },
  methods: {
    handleToolCompleted({ name, args } = {}) {
      if (name !== TOOL_NAME || !args || typeof args !== 'object') return;

      const availableNames = new Set(this.permissions.map((p) => p.name));

      if (Array.isArray(args.select)) {
        const toAdd = args.select.filter((n) => availableNames.has(n));
        if (toAdd.length > 0) {
          this.$emit('permissions-selected', toAdd);
        }
      }

      if (Array.isArray(args.clear)) {
        const toRemove = args.clear.filter((n) => availableNames.has(n));
        if (toRemove.length > 0) {
          this.$emit('permissions-cleared', toRemove);
        }
      }
    },
  },
  AGENT,
  PREDEFINED_PROMPTS,
  WELCOME_MESSAGE,
};
</script>

<template>
  <li v-if="agenticAvailable" class="gl-ml-auto gl-flex gl-items-center gl-pl-3">
    <open-agentic-chat-button
      :button-text="$options.i18n.buttonLabel"
      :resource-id="resourceId"
      :agent="$options.AGENT"
      :welcome-message="$options.WELCOME_MESSAGE"
      :predefined-prompts="$options.PREDEFINED_PROMPTS"
      :button-options="buttonOptions"
      @tool-completed="handleToolCompleted"
    />
  </li>
</template>
