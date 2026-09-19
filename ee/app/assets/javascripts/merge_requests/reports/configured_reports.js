export { hasCodeQualityReport } from '~/merge_requests/reports/configured_reports';

export const hasLicenseComplianceReport = (mr) => Boolean(mr?.enabledReports?.licenseScanning);

export const hasLoadPerformanceReport = (mr) => Boolean(mr?.loadPerformance?.head_path);

export const hasMetricsReport = (mr) => Boolean(mr?.metricsReportsPath);
