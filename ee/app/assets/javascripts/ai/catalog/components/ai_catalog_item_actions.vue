<script>
import {
  GlButton,
  GlDisclosureDropdown,
  GlDisclosureDropdownItem,
  GlIcon,
  GlModalDirective,
  GlTooltipDirective,
  GlSprintf,
  GlTooltip,
} from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { isLoggedIn } from '~/lib/utils/common_utils';
import { helpPagePath } from '~/helpers/help_page_helper';
import { InternalEvents } from '~/tracking';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import glAbilitiesMixin from '~/vue_shared/mixins/gl_abilities_mixin';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ConfirmActionModal from '~/vue_shared/components/confirm_action_modal.vue';
import {
  AI_CATALOG_ITEM_LABELS,
  AI_CATALOG_TYPE_AGENT,
  TRACK_EVENT_ENABLE_AI_CATALOG_ITEM,
  TRACK_EVENT_DISABLE_AI_CATALOG_ITEM,
  TRACK_EVENT_DELETE_AI_CATALOG_ITEM,
  TRACK_EVENT_DUPLICATE_AI_CATALOG_ITEM,
  TRACK_EVENT_ITEM_TYPES,
  TRACK_EVENT_ORIGIN_EXPLORE,
  TRACK_EVENT_ORIGIN_PROJECT,
  TRACK_EVENT_ORIGIN_GROUP,
  TRACK_EVENT_PAGE_SHOW,
} from '../constants';
import {
  canAdminAiCatalogItem,
  canDeleteAiCatalogItem,
  canDuplicateAiCatalogItem,
  canEnableAiCatalogItem,
  canEnableAiCatalogItemInCurrentContext,
  canReportAiCatalogItem,
} from '../permissions';
import {
  getAiCatalogItemOwningProjectName,
  isAiCatalogItemEnabled,
  isAiCatalogItemOutsideOwningProject,
  showEnableFromGlobalAction,
} from '../capabilities';
import aiCatalogProjectsMaintainerQuery from '../graphql/queries/ai_catalog_projects_maintainer.query.graphql';
import AiCatalogItemConsumerModal from './ai_catalog_item_consumer_modal.vue';
import AiCatalogItemDeleteModal from './ai_catalog_item_delete_modal.vue';
import AiCatalogItemReportModal from './ai_catalog_item_report_modal.vue';

export default {
  name: 'AiCatalogItemActions',
  components: {
    GlButton,
    GlDisclosureDropdown,
    GlDisclosureDropdownItem,
    GlIcon,
    GlSprintf,
    GlTooltip,
    ConfirmActionModal,
    AiCatalogItemConsumerModal,
    AiCatalogItemDeleteModal,
    AiCatalogItemReportModal,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  mixins: [InternalEvents.mixin(), glAbilitiesMixin(), glFeatureFlagsMixin()],
  inject: {
    isGlobalNamespace: {},
    isProjectNamespace: {},
    isGroupNamespace: {},
    projectId: {
      default: null,
    },
    projectPath: {
      default: null,
    },
    groupPath: {
      default: null,
    },
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    itemRoutes: {
      type: Object,
      required: true,
    },
    disableFn: {
      type: Function,
      required: false,
      default: () => {},
    },
    deleteFn: {
      type: Function,
      required: true,
    },
    disableConfirmMessage: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['add-to-target', 'report-item'],
  data() {
    return {
      showDeleteModal: false,
      showDisableModal: false,
      projectsIsUserMaintainer: [],
    };
  },
  apollo: {
    projectsIsUserMaintainer: {
      query: aiCatalogProjectsMaintainerQuery,
      skip() {
        return !this.isGlobalNamespace;
      },
      update: (data) => data.projects?.nodes || [],
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    canAdmin() {
      return canAdminAiCatalogItem(this.item, { isGroupNamespace: this.isGroupNamespace });
    },
    canAdminConsumer() {
      return Boolean(this.glAbilities.adminAiCatalogItemConsumer);
    },
    canReport() {
      return canReportAiCatalogItem({ glAbilities: this.glAbilities, item: this.item });
    },
    canHardDelete() {
      return canDeleteAiCatalogItem({ glAbilities: this.glAbilities });
    },
    canUse() {
      return isLoggedIn();
    },
    canEnable() {
      return canEnableAiCatalogItem({
        projectsIsUserMaintainer: this.projectsIsUserMaintainer,
        canAdminConsumer: this.canAdminConsumer,
        isGlobalNamespace: this.isGlobalNamespace,
        isOutsideOwningProject: this.isOutsideOwningProject,
      });
    },
    isOutsideOwningProject() {
      return isAiCatalogItemOutsideOwningProject(this.item, {
        isProjectNamespace: this.isProjectNamespace,
        projectId: this.projectId,
      });
    },
    isEnabled() {
      return isAiCatalogItemEnabled(this.item, { isProjectNamespace: this.isProjectNamespace });
    },
    showDisable() {
      if (this.isFoundationalAgent) {
        return false;
      }
      return this.canAdminConsumer && !this.isGlobalNamespace && this.isEnabled;
    },
    isFoundationalAgent() {
      return this.item.foundational && this.item.itemType === AI_CATALOG_TYPE_AGENT;
    },
    showEnable() {
      if (this.isFoundationalAgent) {
        return false;
      }
      if (this.item.public) {
        return this.canAdminConsumer && this.isProjectNamespace;
      }
      return this.canAdminConsumer && this.isProjectNamespace && !this.isEnabled;
    },
    showDuplicate() {
      return canDuplicateAiCatalogItem(this.item, {
        isGlobalNamespace: this.isGlobalNamespace,
        isGroupNamespace: this.isGroupNamespace,
        glAbilities: this.glAbilities,
        glFeatures: this.glFeatures,
      });
    },
    showDropdown() {
      return (
        (this.showDisable || this.showDuplicate || this.canAdmin || this.canReport) &&
        (!this.isGlobalNamespace || this.glAbilities.readAiCatalog || this.canAdmin)
      );
    },
    showEnableFromGlobal() {
      return showEnableFromGlobalAction(this.item, {
        isGlobalNamespace: this.isGlobalNamespace,
      });
    },
    showEnableButton() {
      return this.showEnableFromGlobal || this.showEnable;
    },
    enableButtonDisabled() {
      return !canEnableAiCatalogItemInCurrentContext(this.item, {
        isGlobalNamespace: this.isGlobalNamespace,
        isProjectNamespace: this.isProjectNamespace,
        isEnabled: this.isEnabled,
        readAiCatalog: Boolean(this.glAbilities.readAiCatalog),
        projectId: this.projectId,
      });
    },
    enableButtonTooltip() {
      if (!isLoggedIn()) {
        return s__('AICatalog|Log in to enable');
      }
      if (!this.glAbilities.readAiCatalog && this.isGlobalNamespace) {
        return s__('AICatalog|Contact your administrator to enable GitLab Duo');
      }
      if (this.isOutsideOwningProject) {
        return sprintf(
          s__(
            "AICatalog|This private %{itemType} is managed by %{projectName} and can't be enabled from this project.",
          ),
          {
            itemType: this.itemTypeLabel ?? '',
            projectName: getAiCatalogItemOwningProjectName(this.item) ?? '',
          },
        );
      }
      if (this.isAlreadyEnabledPrivateItem) {
        return sprintf(s__('AICatalog|This %{itemType} is already enabled.'), {
          itemType: this.itemTypeLabel ?? '',
        });
      }
      return null;
    },
    isAlreadyEnabledPrivateItem() {
      return Boolean(this.item && this.item.public === false && this.isEnabled);
    },
    itemTypeLabel() {
      return AI_CATALOG_ITEM_LABELS[this.item.itemType];
    },
    disableConfirmTitle() {
      return sprintf(s__('AICatalog|Disable %{itemType}'), {
        itemType: this.itemTypeLabel,
      });
    },
    origin() {
      if (this.isGlobalNamespace) return TRACK_EVENT_ORIGIN_EXPLORE;
      if (this.isProjectNamespace) return TRACK_EVENT_ORIGIN_PROJECT;
      return TRACK_EVENT_ORIGIN_GROUP;
    },
  },
  methods: {
    onClickDelete() {
      this.showDeleteModal = true;
      this.trackEvent(TRACK_EVENT_DELETE_AI_CATALOG_ITEM, {
        label: TRACK_EVENT_ITEM_TYPES[this.item.itemType],
        origin: this.origin,
        page: TRACK_EVENT_PAGE_SHOW,
      });
    },
    onClickEnable() {
      this.trackEvent(TRACK_EVENT_ENABLE_AI_CATALOG_ITEM, {
        label: TRACK_EVENT_ITEM_TYPES[this.item.itemType],
        origin: this.origin,
        page: TRACK_EVENT_PAGE_SHOW,
      });
    },
    onClickDisable() {
      this.showDisableModal = true;
      this.trackEvent(TRACK_EVENT_DISABLE_AI_CATALOG_ITEM, {
        label: TRACK_EVENT_ITEM_TYPES[this.item.itemType],
        origin: this.origin,
        page: TRACK_EVENT_PAGE_SHOW,
      });
    },
    onClickDuplicate() {
      this.trackEvent(TRACK_EVENT_DUPLICATE_AI_CATALOG_ITEM, {
        label: TRACK_EVENT_ITEM_TYPES[this.item.itemType],
        origin: this.origin,
        page: TRACK_EVENT_PAGE_SHOW,
      });
      this.$router.push({
        name: this.itemRoutes.duplicate,
        params: { id: this.$route.params.id },
      });
    },
  },
  adminModeDocsLink: helpPagePath('/administration/settings/sign_in_restrictions', {
    anchor: 'admin-mode',
  }),
  toggleId: 'more-actions-dropdown',
};
</script>

<template>
  <div class="gl-flex gl-gap-3">
    <gl-button
      v-if="canAdmin"
      :to="{ name: itemRoutes.edit, params: { id: $route.params.id } }"
      category="secondary"
      icon="pencil"
      data-testid="edit-button"
    >
      {{ __('Edit') }}
    </gl-button>
    <span
      v-if="showEnableButton"
      v-gl-tooltip
      :title="enableButtonTooltip"
      class="gl-inline-block"
      data-testid="enable-button-wrapper"
    >
      <gl-button
        v-gl-modal="enableButtonDisabled ? '' : 'enable-item-modal'"
        variant="confirm"
        category="primary"
        :disabled="enableButtonDisabled"
        data-testid="enable-button"
        @click="onClickEnable"
      >
        {{
          (isProjectNamespace && isEnabled) || isAlreadyEnabledPrivateItem
            ? __('Enabled')
            : __('Enable')
        }}
      </gl-button>
    </span>
    <gl-disclosure-dropdown
      v-if="showDropdown"
      :toggle-id="$options.toggleId"
      :toggle-text="__('More actions')"
      category="tertiary"
      icon="ellipsis_v"
      no-caret
      text-sr-only
      data-testid="more-actions-dropdown"
    >
      <gl-disclosure-dropdown-item
        v-if="showDuplicate"
        data-testid="duplicate-button"
        @action="onClickDuplicate"
      >
        <template #list-item>
          <span class="gl-flex gl-gap-2">
            <gl-icon name="duplicate" variant="current" aria-hidden="true" />
            {{ s__('AICatalog|Duplicate') }}
          </span>
        </template>
      </gl-disclosure-dropdown-item>
      <gl-disclosure-dropdown-item
        v-if="showDisable"
        data-testid="disable-button"
        @action="onClickDisable"
      >
        <template #list-item>
          <span class="gl-flex gl-gap-2">
            <gl-icon name="cancel" variant="current" aria-hidden="true" />
            {{ __('Disable') }}
          </span>
        </template>
      </gl-disclosure-dropdown-item>
      <gl-disclosure-dropdown-item
        v-if="canReport"
        v-gl-modal="'ai-catalog-item-report-modal'"
        variant="danger"
        data-testid="report-button"
      >
        <template #list-item>
          <span class="gl-flex gl-gap-2">
            <gl-icon name="flag" variant="current" aria-hidden="true" />
            {{ s__('AICatalog|Report to admin') }}
          </span>
        </template>
      </gl-disclosure-dropdown-item>
      <gl-disclosure-dropdown-item
        v-if="canAdmin"
        variant="danger"
        data-testid="delete-button"
        @action="onClickDelete"
      >
        <template #list-item>
          <span class="gl-flex gl-gap-2">
            <gl-icon
              :name="canHardDelete ? 'remove' : 'eye-slash'"
              variant="current"
              aria-hidden="true"
            />
            {{ canHardDelete ? __('Delete') : __('Hide') }}
          </span>
        </template>
      </gl-disclosure-dropdown-item>
    </gl-disclosure-dropdown>
    <gl-tooltip :target="$options.toggleId" boundary="viewport" placement="top" triggers="hover">{{
      __('More actions')
    }}</gl-tooltip>

    <ai-catalog-item-delete-modal
      v-if="canAdmin && showDeleteModal"
      :item="item"
      :delete-fn="deleteFn"
      @close="showDeleteModal = false"
    />
    <confirm-action-modal
      v-if="showDisableModal"
      modal-id="disable-item-modal"
      variant="danger"
      :title="disableConfirmTitle"
      :action-fn="disableFn"
      :action-text="__('Disable')"
      @close="showDisableModal = false"
    >
      <gl-sprintf :message="disableConfirmMessage">
        <template #name>
          <strong class="gl-wrap-anywhere">{{ item.name }}</strong>
        </template>
      </gl-sprintf>
    </confirm-action-modal>
    <ai-catalog-item-consumer-modal
      v-if="canUse"
      modal-id="enable-item-modal"
      :item="item"
      :can-enable="canEnable"
      @submit="$emit('add-to-target', $event)"
    />
    <ai-catalog-item-report-modal
      v-if="canReport"
      :item="item"
      @submit="$emit('report-item', $event)"
    />
  </div>
</template>
