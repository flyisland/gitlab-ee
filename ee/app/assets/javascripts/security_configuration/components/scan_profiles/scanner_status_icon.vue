<script>
import { GlIcon } from '@gitlab/ui';
import {
  SCAN_PROFILE_SCANNER_HEALTH_ACTIVE,
  SCAN_PROFILE_SCANNER_HEALTH_FAILED,
  SCAN_PROFILE_SCANNER_HEALTH_PENDING,
  SCAN_PROFILE_SCANNER_HEALTH_STALE,
  SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED,
  SCAN_PROFILE_SCANNER_HEALTH_WARNING,
} from '~/security_configuration/constants';

const STATUS_ICONS = {
  [SCAN_PROFILE_SCANNER_HEALTH_PENDING]: 'status-waiting',
  [SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED]: 'clear',
  [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE]: 'status-success',
  [SCAN_PROFILE_SCANNER_HEALTH_WARNING]: 'status_warning',
  [SCAN_PROFILE_SCANNER_HEALTH_FAILED]: 'status-failed',
  [SCAN_PROFILE_SCANNER_HEALTH_STALE]: 'status-scheduled',
};

const STATUS_ICON_CLASSES = {
  [SCAN_PROFILE_SCANNER_HEALTH_PENDING]: 'gl-text-subtle',
  [SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED]: 'gl-text-subtle',
  [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE]: 'gl-text-success',
  [SCAN_PROFILE_SCANNER_HEALTH_WARNING]: 'gl-text-warning',
  [SCAN_PROFILE_SCANNER_HEALTH_FAILED]: 'gl-text-danger',
  [SCAN_PROFILE_SCANNER_HEALTH_STALE]: 'gl-text-subtle',
};

export default {
  name: 'ScannerStatusIcon',
  components: { GlIcon },
  props: {
    status: {
      type: String,
      required: true,
    },
  },
  computed: {
    iconName() {
      return STATUS_ICONS[this.status?.toLowerCase()] || 'status_failed';
    },
    iconClass() {
      return STATUS_ICON_CLASSES[this.status?.toLowerCase()] || 'gl-text-subtle';
    },
  },
};
</script>

<template>
  <gl-icon :name="iconName" :class="iconClass" />
</template>
