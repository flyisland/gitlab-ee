<script>
import {
  GlAlert,
  GlButton,
  GlButtonGroup,
  GlDisclosureDropdown,
  GlDisclosureDropdownItem,
  GlIcon,
  GlPopover,
  GlLink,
  GlToast,
  GlLoadingIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import Vue from 'vue';
import { PROMO_URL } from '~/constants';
import {
  SCAN_PROFILE_CATEGORIES,
  SCAN_PROFILE_I18N,
  SCAN_PROFILE_PROMO_ITEMS,
  SCAN_PROFILE_SCANNER_HEALTH_ACTIVE,
  SCAN_PROFILE_SCANNER_HEALTH_FAILED,
  SCAN_PROFILE_SCANNER_HEALTH_STALE,
  SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED,
  SCAN_PROFILE_SCANNER_HEALTH_WARNING,
  SCAN_PROFILE_TYPE_SECRET_DETECTION,
} from '~/security_configuration/constants';
import ScanProfileTable from '~/security_configuration/components/scan_profiles/scan_profile_table.vue';
import availableProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import projectProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/project_security_scan_profiles.query.graphql';
import attachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_attach.mutation.graphql';
import detachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_detach.mutation.graphql';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { n__, s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  statusIcon,
  statusIconClass,
} from 'ee/security_configuration/components/scan_profiles/utils';
import DisableScanProfileConfirmationModal from './disable_scan_profile_confirmation_modal.vue';
import ScanProfileDetailsModal from './scan_profile_details_modal.vue';
import InsufficientPermissionsPopover from './insufficient_permissions_popover.vue';
import ScanProfileLaunchModal from './scan_profile_launch_modal.vue';
import JobDetailsPopover from './job_details_popover.vue';
import TroubleshootJobDrawer from './troubleshoot_job_drawer.vue';

Vue.use(GlToast);

const APPLICATION_SECURITY_TESTING_PROMO_URL = `${PROMO_URL}/solutions/application-security-testing/`;

export default {
  name: 'ScanProfileConfiguration',
  components: {
    GlButtonGroup,
    GlButton,
    GlIcon,
    GlAlert,
    GlLink,
    ScanProfileTable,
    DisableScanProfileConfirmationModal,
    ScanProfileDetailsModal,
    JobDetailsPopover,
    InsufficientPermissionsPopover,
    ScanProfileLaunchModal,
    GlDisclosureDropdown,
    GlDisclosureDropdownItem,
    GlLoadingIcon,
    GlPopover,
    TroubleshootJobDrawer,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin, glFeatureFlagsMixin()],
  inject: ['projectFullPath', 'groupFullPath', 'canApplyProfiles', 'securityScanProfilesLicensed'],
  SCAN_PROFILE_I18N,
  APPLICATION_SECURITY_TESTING_PROMO_URL,
  apollo: {
    availableProfiles: {
      skip() {
        return !this.securityScanProfilesLicensed;
      },
      query: availableProfilesQuery,
      variables() {
        return { fullPath: this.groupFullPath, gitlabRecommended: true };
      },
      update: (data) => data?.group?.availableSecurityScanProfiles || [],
      error() {
        this.showError(SCAN_PROFILE_I18N.errorLoadingProfiles);
      },
    },
    attachedProfiles: {
      skip() {
        return !this.securityScanProfilesLicensed;
      },
      query: projectProfilesQuery,
      variables() {
        return { fullPath: this.projectFullPath };
      },
      update: (data) => data?.project?.securityScanProfiles || [],
      result({ data, error }) {
        if (!error && data) {
          this.projectId = data?.project?.id;
        }
      },
      error() {
        this.showError(SCAN_PROFILE_I18N.errorLoadingProfiles);
      },
    },
  },
  data() {
    return {
      drawerData: null,
      activePopover: null,
      isDrawerOpen: false,
      projectId: null,
      submittingProfileId: null,
      errorMessage: null,
      previewProfileId: '',
      previewScanType: '',
      previewModalVisible: false,
      disableModalVisible: false,
      disablingScanType: null,
      availableProfiles: [],
      attachedProfiles: [],
      statuses: this.setStatusesMock(),
      popoverCloseTimeout: null,
    };
  },
  computed: {
    isLoading() {
      return (
        this.$apollo.queries.availableProfiles.loading ||
        this.$apollo.queries.attachedProfiles.loading
      );
    },
    getScannerMetadata() {
      return (scanType) => SCAN_PROFILE_CATEGORIES[scanType] || {};
    },
    isProfileAttached() {
      return (profileId) => {
        return this.attachedProfiles.some((p) => p.id === profileId);
      };
    },
    getAttachedProfileForScanType() {
      return (scanType) => {
        return this.attachedProfiles.find((p) => p.scanType === scanType);
      };
    },
    tableItems() {
      if (!this.securityScanProfilesLicensed) return SCAN_PROFILE_PROMO_ITEMS;

      return this.availableProfiles
        .filter((profile) => Boolean(SCAN_PROFILE_CATEGORIES[profile.scanType]))
        .map((profile) => {
          const statusData = this.getStatusForProfile(profile);
          return {
            id: profile.id,
            name: profile.name,
            description: profile.description,
            scanType: profile.scanType,
            gitlabRecommended: profile.gitlabRecommended,
            isConfigured: this.isProfileAttached(profile.id),
            ...statusData,
          };
        });
    },
    disableDropdownItem() {
      return {
        text: this.$options.SCAN_PROFILE_I18N.disable,
        extraAttrs: {
          disabled: !this.canApplyProfiles || !this.securityScanProfilesLicensed,
        },
      };
    },
  },
  beforeDestroy() {
    clearTimeout(this.popoverCloseTimeout);
  },
  methods: {
    statusIconClass,
    statusIcon,
    setStatusesMock() {
      return [
        {
          scanType: SCAN_PROFILE_TYPE_SECRET_DETECTION,
          id: 'gid://gitlab/Security::ScanProfile/4',
          status: SCAN_PROFILE_SCANNER_HEALTH_ACTIVE,
          consecutiveFailureCount: 2,
          consecutiveSuccessCount: 12,
          lastScanAt: '2026-03-17T14:30:00Z',
          buildId: 'gid://gitlab/CommitStatus/123',
        },
      ];
    },
    getStatusForProfile(profile) {
      const defaultStatus = {
        status: null,
        consecutiveFailureCount: null,
        consecutiveSuccessCount: null,
        lastScanAt: null,
        buildId: null,
      };

      if (!this.glFeatures.securityScanProfilesStatusIndicators) return defaultStatus;

      const matched = this.statuses.find((s) => s.id === profile.id);
      const { status, ...rest } = matched ?? defaultStatus;
      return { status: status?.toLowerCase(), ...rest };
    },
    showError(message) {
      this.errorMessage = message;
      setTimeout(() => {
        this.errorMessage = null;
      }, 5000);
    },
    showToast(message) {
      this.$toast.show(message);
    },
    getButtonId(item) {
      return item.isConfigured ? `disable-button-${item.id}` : `apply-button-${item.id}`;
    },
    async applyProfile(profileId) {
      if (!this.projectId || !profileId) return;

      this.submittingProfileId = profileId;
      this.errorMessage = null;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: attachMutation,
          variables: {
            input: {
              securityScanProfileId: profileId,
              projectIds: [this.projectId],
            },
          },
          refetchQueries: [
            {
              query: projectProfilesQuery,
              variables: { fullPath: this.projectFullPath },
            },
          ],
        });

        const mutationErrors = data?.securityScanProfileAttach?.errors;
        if (mutationErrors?.length) {
          this.showError(mutationErrors.join(', '));
        } else {
          this.showToast(SCAN_PROFILE_I18N.successApplying);
          if (this.previewModalVisible) {
            this.closePreview();
          }
        }
      } catch (error) {
        this.showError(SCAN_PROFILE_I18N.errorApplying);
      } finally {
        this.submittingProfileId = null;
      }
    },
    openDisableModal(scanType) {
      this.disablingScanType = scanType;
      this.disableModalVisible = true;
    },
    async detachProfile() {
      const attachedProfile = this.getAttachedProfileForScanType(this.disablingScanType);
      if (!attachedProfile || !this.projectId) return;

      this.disableModalVisible = false;
      this.submittingProfileId = attachedProfile.id;
      this.errorMessage = null;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: detachMutation,
          variables: {
            input: {
              securityScanProfileId: attachedProfile.id,
              projectIds: [this.projectId],
            },
          },
          refetchQueries: [
            {
              query: projectProfilesQuery,
              variables: { fullPath: this.projectFullPath },
            },
          ],
        });

        const mutationErrors = data?.securityScanProfileDetach?.errors;
        if (mutationErrors?.length) {
          this.showError(mutationErrors.join(', '));
        } else {
          this.showToast(SCAN_PROFILE_I18N.successDetaching);
        }
      } catch (error) {
        this.showError(SCAN_PROFILE_I18N.errorDetaching);
      } finally {
        this.submittingProfileId = null;
        this.disablingScanType = null;
      }
    },
    openPreview(profileId, scanType) {
      this.previewProfileId = profileId;
      this.previewScanType = scanType;
      this.previewModalVisible = true;
    },
    closePreview() {
      this.previewModalVisible = false;
      this.previewProfileId = '';
      this.previewScanType = '';
    },
    scannerStatusDetail(item) {
      const { status, consecutiveSuccessCount, consecutiveFailureCount } = item;

      switch (status) {
        case SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED:
          return this.$options.SCAN_PROFILE_I18N.applyToEnable;
        case SCAN_PROFILE_SCANNER_HEALTH_ACTIVE:
          return n__(
            'SecurityProfiles|Last %d scan successful',
            'SecurityProfiles|Last %d scans successful',
            consecutiveSuccessCount,
          );

        case SCAN_PROFILE_SCANNER_HEALTH_WARNING:
          return n__(
            'SecurityProfiles|Last %d scan failed',
            'SecurityProfiles|Last %d scans failed',
            consecutiveFailureCount,
          );

        case SCAN_PROFILE_SCANNER_HEALTH_FAILED:
          return n__(
            'SecurityProfiles|Last %d scan failed',
            'SecurityProfiles|Last %d scans failed',
            consecutiveFailureCount,
          );

        case SCAN_PROFILE_SCANNER_HEALTH_STALE:
          return this.$options.SCAN_PROFILE_I18N.coverageMayBeOutdated;
        default:
          return '';
      }
    },
    scannerStatus(item) {
      return item.status ? humanize(item.status) : '';
    },
    lastScanLinkText(item) {
      return item.status === SCAN_PROFILE_SCANNER_HEALTH_FAILED
        ? `${s__('SecurityProfiles|View failed job #')}${getIdFromGraphQLId(item.buildId)}`
        : `${s__('SecurityProfiles|View job #')}${getIdFromGraphQLId(item.buildId)}`;
    },
    formattedLastScan(item) {
      return this.timeFormatted(item.lastScanAt);
    },
    isFailedOrWarningStatus(item) {
      return [SCAN_PROFILE_SCANNER_HEALTH_WARNING, SCAN_PROFILE_SCANNER_HEALTH_FAILED].includes(
        item.status,
      );
    },
    getScannerDetailsTitle(item) {
      const titles = {
        [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE]: s__('SecurityProfiles|Scan successful'),
        [SCAN_PROFILE_SCANNER_HEALTH_WARNING]: s__('SecurityProfiles|Scan warning'),
        [SCAN_PROFILE_SCANNER_HEALTH_FAILED]: s__('SecurityProfiles|Scan failed'),
        [SCAN_PROFILE_SCANNER_HEALTH_STALE]: s__('SecurityProfiles|Scan outdated'),
      };
      return titles[item.status] || '';
    },
    openDrawer(item, jobData) {
      this.activePopover = null;
      this.drawerData = {
        ...jobData,
        ...item,
        fullPath: this.projectFullPath,
      };
      this.isDrawerOpen = true;
    },
    openPopover(id) {
      clearTimeout(this.popoverCloseTimeout);
      this.activePopover = id;
    },
    closePopover() {
      this.popoverCloseTimeout = setTimeout(() => {
        this.activePopover = null;
      }, 500);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="errorMessage"
      variant="danger"
      class="gl-mb-5"
      dismissible
      @dismiss="errorMessage = null"
    >
      {{ errorMessage }}
    </gl-alert>

    <scan-profile-table :table-items="tableItems" :loading="isLoading">
      <template #cell(name)="{ item }">
        <div class="gl-flex gl-items-center">
          <template v-if="item.isConfigured">
            <gl-link @click="openPreview(item.id, item.scanType)">
              {{ item.name }}
            </gl-link>
          </template>
          <span v-else class="gl-text-subtle">
            {{ $options.SCAN_PROFILE_I18N.noProfile }}
          </span>
        </div>
      </template>

      <template #cell(status)="{ item }">
        <div v-if="!securityScanProfilesLicensed" class="gl-flex gl-flex-col">
          <span class="gl-font-weight-bold">
            {{ __('Available with Ultimate') }}
          </span>
          <span class="gl-mt-1 gl-text-sm gl-text-subtle">
            <gl-link
              :href="$options.APPLICATION_SECURITY_TESTING_PROMO_URL"
              target="_blank"
              data-testid="learn-more-ultimate-link"
            >
              {{ __('Learn more about the Ultimate security suite') }}
              <gl-icon name="external-link" :aria-label="__('(external link)')" />
            </gl-link>
          </span>
        </div>
        <div
          v-else-if="glFeatures.securityScanProfilesStatusIndicators"
          class="gl-flex gl-items-center"
        >
          <gl-icon
            data-testid="status-icon"
            :name="statusIcon(item.status)"
            :class="statusIconClass(item.status)"
            class="gl-mr-3 gl-self-start"
          />
          <div class="gl-flex gl-flex-col">
            <span class="gl-font-weight-bold">
              {{ scannerStatus(item) }}
            </span>
            <span class="gl-mt-1 gl-text-sm gl-text-subtle">
              {{ scannerStatusDetail(item) }}
            </span>
          </div>
        </div>
        <div v-else class="gl-flex gl-items-center">
          <gl-icon
            :name="item.isConfigured ? 'check-circle-filled' : 'close'"
            :class="item.isConfigured ? 'gl-text-success' : 'gl-text-subtle'"
            class="gl-mr-3 gl-self-start"
          />
          <div class="gl-flex gl-flex-col">
            <span class="gl-font-weight-bold">
              {{
                item.isConfigured
                  ? $options.SCAN_PROFILE_I18N.active
                  : $options.SCAN_PROFILE_I18N.notConfigured
              }}
            </span>
            <span v-if="!item.isConfigured" class="gl-mt-1 gl-text-sm gl-text-subtle">
              {{ $options.SCAN_PROFILE_I18N.applyToEnable }}
            </span>
          </div>
        </div>
      </template>

      <template #cell(last-scan)="{ item }">
        <div v-if="item.lastScanAt" data-testid="last-scan" class="gl-flex gl-flex-col">
          {{ formattedLastScan(item) }}
          <gl-link
            :id="`scanner-details-${item.id}`"
            class="gl-mt-1"
            @mouseenter="openPopover(item.id)"
            @mouseleave="closePopover"
            @focus="openPopover(item.id)"
            @blur="activePopover = null"
          >
            {{ lastScanLinkText(item) }}
          </gl-link>
          <gl-popover
            :id="`popover-${item.id}`"
            :target="`scanner-details-${item.id}`"
            :title="getScannerDetailsTitle(item)"
            :show="activePopover === item.id"
            triggers=""
          >
            <div @mouseenter="openPopover(item.id)" @mouseleave="closePopover">
              <job-details-popover
                :build-id="item.buildId"
                :project-full-path="projectFullPath"
                @open-drawer="openDrawer(item, $event)"
              />
            </div>
          </gl-popover>
        </div>
        <span v-else>{{ __('—') }}</span>
      </template>

      <template #cell(actions)="{ item }">
        <div v-if="!item.isConfigured">
          <gl-button-group>
            <!-- Apply button -->
            <gl-button
              :id="getButtonId(item)"
              variant="confirm"
              category="secondary"
              :loading="submittingProfileId === item.id"
              :disabled="!canApplyProfiles || !securityScanProfilesLicensed || !item.id"
              class="!gl-rounded-r-none"
              @click="applyProfile(item.id)"
            >
              {{ $options.SCAN_PROFILE_I18N.applyDefault }}
              <gl-icon
                v-if="!canApplyProfiles"
                name="lock"
                class="gl-ml-2"
                :aria-label="$options.SCAN_PROFILE_I18N.accessLevelTooltipDescription"
              />
            </gl-button>
            <!-- Preview button -->
            <gl-button
              v-gl-tooltip
              variant="confirm"
              category="secondary"
              icon="eye"
              :aria-label="s__(`SecurityProfiles|Preview profile`)"
              :title="$options.SCAN_PROFILE_I18N.previewDefault"
              :disabled="submittingProfileId === item.id || !securityScanProfilesLicensed"
              @click="openPreview(item.id, item.scanType)"
            />
          </gl-button-group>
          <insufficient-permissions-popover
            v-if="!canApplyProfiles && securityScanProfilesLicensed"
            :target="getButtonId(item)"
            placement="top"
          />
        </div>

        <div v-else>
          <div v-if="glFeatures.securityScanProfilesStatusIndicators">
            <gl-disclosure-dropdown
              category="tertiary"
              variant="default"
              size="small"
              icon="ellipsis_v"
              no-caret
            >
              <!-- Troubleshoot Failure button -->
              <gl-disclosure-dropdown-item v-if="isFailedOrWarningStatus(item)">
                <template #list-item>
                  {{ $options.SCAN_PROFILE_I18N.troubleshootFailure }}
                </template>
              </gl-disclosure-dropdown-item>

              <!-- Disable button -->
              <gl-disclosure-dropdown-item
                :id="getButtonId(item)"
                :item="disableDropdownItem"
                variant="danger"
                category="secondary"
                @action="openDisableModal(item.scanType)"
              >
                <template #list-item>
                  <span class="gl-flex gl-items-center gl-gap-2">
                    <gl-loading-icon v-if="submittingProfileId === item.id" />
                    {{ $options.SCAN_PROFILE_I18N.disable }}
                    <gl-icon
                      v-if="!canApplyProfiles"
                      name="lock"
                      class="gl-ml-2"
                      :aria-label="$options.SCAN_PROFILE_I18N.accessLevelTooltipDescription"
                    />
                  </span>
                </template>
              </gl-disclosure-dropdown-item>
            </gl-disclosure-dropdown>
          </div>

          <div v-else :id="getButtonId(item)">
            <gl-button
              variant="danger"
              category="secondary"
              :loading="submittingProfileId === item.id"
              :disabled="!canApplyProfiles || !securityScanProfilesLicensed"
              @click="openDisableModal(item.scanType)"
            >
              {{ $options.SCAN_PROFILE_I18N.disable }}
              <gl-icon
                v-if="!canApplyProfiles"
                name="lock"
                class="gl-ml-2"
                :aria-label="$options.SCAN_PROFILE_I18N.accessLevelTooltipDescription"
              />
            </gl-button>
          </div>

          <insufficient-permissions-popover
            v-if="!canApplyProfiles"
            :target="getButtonId(item)"
            placement="bottom"
          />
        </div>
      </template>
    </scan-profile-table>

    <scan-profile-details-modal
      :profile-id="previewProfileId"
      :scan-type="previewScanType"
      :visible="previewModalVisible"
      :is-attached="isProfileAttached(previewProfileId)"
      @apply="applyProfile"
      @close="closePreview"
    />

    <disable-scan-profile-confirmation-modal
      :visible="disableModalVisible"
      :scanner-name="disablingScanType ? getScannerMetadata(disablingScanType).name : ''"
      @confirm="detachProfile"
      @cancel="disableModalVisible = false"
    />

    <scan-profile-launch-modal v-if="securityScanProfilesLicensed" />

    <troubleshoot-job-drawer
      v-if="isDrawerOpen"
      :drawer-data="drawerData"
      :open-drawer="isDrawerOpen"
      @close-drawer="isDrawerOpen = false"
    />
  </div>
</template>
