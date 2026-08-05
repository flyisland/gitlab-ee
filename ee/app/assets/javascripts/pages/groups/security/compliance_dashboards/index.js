import initComplianceDashboard from 'ee/compliance_dashboard/compliance_dashboard_bundle';

async function init() {
  if (gon.features?.vue3MigrateComplianceCenter) {
    try {
      const { default: initVue3ComplianceDashboard } = await import(
        'ee/compliance_dashboard/compliance_dashboard_bundle?vue3'
      );
      initVue3ComplianceDashboard();
      return;
    } catch {
      // Fall back to Vue 2 if the Vue 3 bundle fails to load
    }
  }

  initComplianceDashboard();
}

init();
