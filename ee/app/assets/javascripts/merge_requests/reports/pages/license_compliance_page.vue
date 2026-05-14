<script>
import LicenseComplianceProvider from 'ee/merge_requests/reports/components/license_compliance_provider.vue';
import LicenseComplianceContent from './license_compliance_content.vue';

export default {
  name: 'LicenseCompliancePage',
  components: {
    LicenseComplianceProvider,
    LicenseComplianceContent,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <license-compliance-provider :mr="mr">
    <license-compliance-content :mr="mr" />
  </license-compliance-provider>
</template>
