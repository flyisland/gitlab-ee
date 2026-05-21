import { s__ } from '~/locale';
import { idAsOption } from './helpers';

export const RULE_TYPES = [
  {
    id: 'custom_rule',
    label: s__('SecurityOrchestration|Custom Rule'),
    description: s__('SecurityOrchestration|Write custom policy logic using Rego or YAML'),
    icon: 'code',
    fields: [
      {
        key: 'name',
        type: 'text',
        label: s__('SecurityOrchestration|Rule name'),
        placeholder: s__('SecurityOrchestration|Rule name'),
      },
      {
        key: 'language',
        type: 'segment',
        label: s__('SecurityOrchestration|Language'),
        options: [
          { id: 'rego', label: s__('SecurityOrchestration|Rego') },
          { id: 'yaml', label: s__('SecurityOrchestration|YAML') },
        ],
      },
      {
        key: 'definition',
        type: 'textarea',
        label: s__('SecurityOrchestration|Definition'),
        placeholder: s__('SecurityOrchestration|Enter your Rego or YAML rule definition...'),
      },
    ],
  },
  {
    id: 'security_scan_results',
    label: s__('SecurityOrchestration|Security Scan Results'),
    description: s__('SecurityOrchestration|Evaluate security scan findings'),
    icon: 'shield',
    fields: [
      {
        key: 'scanTypes',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Scan Type'),
        options: [
          idAsOption('sast'),
          idAsOption('dast'),
          idAsOption('dependency_scanning'),
          idAsOption('secret_detection'),
          idAsOption('container_scanning'),
          idAsOption('iac_scanning'),
          idAsOption('api_fuzzing'),
        ],
      },
      {
        key: 'minSeverity',
        type: 'select',
        label: s__('SecurityOrchestration|Minimum Severity'),
        options: [
          idAsOption('info'),
          idAsOption('low'),
          idAsOption('medium'),
          idAsOption('high'),
          idAsOption('critical'),
        ],
      },
      {
        key: 'findingOperator',
        type: 'select',
        label: s__('SecurityOrchestration|Finding Count'),
        options: [
          { id: 'gt', label: s__('SecurityOrchestration|greater than') },
          { id: 'lt', label: s__('SecurityOrchestration|less than') },
          { id: 'eq', label: s__('SecurityOrchestration|equals') },
          { id: 'gte', label: s__('SecurityOrchestration|greater than or equals') },
        ],
      },
      {
        key: 'findingCount',
        type: 'text',
        label: s__('SecurityOrchestration|Count Value'),
        placeholder: '',
      },
      {
        key: 'newFindingsOnly',
        type: 'toggle',
        label: s__('SecurityOrchestration|New Findings Only'),
      },
    ],
  },
  {
    id: 'vulnerability_risk_assessment',
    label: s__('SecurityOrchestration|Vulnerability Risk Assessment'),
    description: s__(
      'SecurityOrchestration|Evaluate vulnerability risk based on EPSS, KEV, and other factors',
    ),
    icon: 'warning-solid',
    fields: [
      {
        key: 'epssThreshold',
        type: 'text',
        label: s__('SecurityOrchestration|EPSS Score Threshold'),
        placeholder: '',
      },
      {
        key: 'checkKev',
        type: 'toggle',
        label: s__('SecurityOrchestration|Check KEV (Known Exploited)'),
      },
      {
        key: 'cvssThreshold',
        type: 'text',
        label: s__('SecurityOrchestration|CVSS Score Threshold'),
        placeholder: '',
      },
      {
        key: 'maxFpLikelihood',
        type: 'text',
        label: s__('SecurityOrchestration|Max False Positive Likelihood'),
        placeholder: '',
      },
      {
        key: 'reachability',
        type: 'select',
        label: s__('SecurityOrchestration|Reachability Status'),
        options: [
          idAsOption('any'),
          idAsOption('reachable'),
          idAsOption('potentially_reachable'),
          idAsOption('not_reachable'),
        ],
      },
    ],
  },
  {
    id: 'vulnerability_sla_status',
    label: s__('SecurityOrchestration|Vulnerability SLA Status'),
    description: s__(
      'SecurityOrchestration|Evaluate vulnerabilities based on their SLA due date status',
    ),
    icon: 'clock',
    fields: [
      {
        key: 'slaStatuses',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|SLA Status'),
        options: [
          idAsOption('approaching'),
          idAsOption('exceeded'),
          idAsOption('no_due_date'),
          idAsOption('compliant'),
        ],
      },
      {
        key: 'approachingThreshold',
        type: 'text',
        label: s__('SecurityOrchestration|Approaching Threshold (days)'),
        placeholder: '',
      },
      {
        key: 'overdueThreshold',
        type: 'text',
        label: s__('SecurityOrchestration|Overdue Threshold (days)'),
        placeholder: '',
      },
      {
        key: 'slaSource',
        type: 'select',
        label: s__('SecurityOrchestration|SLA Source'),
        options: [idAsOption('any'), idAsOption('policy'), idAsOption('api'), idAsOption('manual')],
      },
    ],
  },
  {
    id: 'code_coverage',
    label: s__('SecurityOrchestration|Code Coverage'),
    description: s__('SecurityOrchestration|Evaluate code coverage metrics'),
    icon: 'chart',
    fields: [
      {
        key: 'minCoverage',
        type: 'text',
        label: s__('SecurityOrchestration|Minimum Coverage %%'),
        placeholder: '',
      },
      {
        key: 'compareTo',
        type: 'select',
        label: s__('SecurityOrchestration|Compare To'),
        options: [
          idAsOption('absolute'),
          idAsOption('target_branch'),
          idAsOption('previous_commit'),
        ],
      },
      {
        key: 'allowDecrease',
        type: 'toggle',
        label: s__('SecurityOrchestration|Allow Coverage Decrease'),
      },
      {
        key: 'maxDecrease',
        type: 'text',
        label: s__('SecurityOrchestration|Max Allowed Decrease %%'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'test_results',
    label: s__('SecurityOrchestration|Test Results'),
    description: s__('SecurityOrchestration|Evaluate test execution results'),
    icon: 'check-circle',
    fields: [
      {
        key: 'requireAllPass',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require All Tests Pass'),
      },
      {
        key: 'maxFailures',
        type: 'text',
        label: s__('SecurityOrchestration|Maximum Allowed Failures'),
        placeholder: '',
      },
      {
        key: 'requireExecuted',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Tests Executed'),
      },
      {
        key: 'minTestCount',
        type: 'text',
        label: s__('SecurityOrchestration|Minimum Test Count'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'project_attributes',
    label: s__('SecurityOrchestration|Project Attributes'),
    description: s__('SecurityOrchestration|Check project metadata and compliance attributes'),
    icon: 'project',
    fields: [
      {
        key: 'requiredLabels',
        type: 'text',
        label: s__('SecurityOrchestration|Required Labels'),
        placeholder: s__('SecurityOrchestration|e.g., PCI, SOC2, HIPAA'),
      },
      {
        key: 'complianceFrameworks',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Compliance Framework'),
        options: [
          { id: 'pci_dss', label: s__('SecurityOrchestration|PCI-DSS') },
          { id: 'soc2', label: s__('SecurityOrchestration|SOC2') },
          { id: 'hipaa', label: s__('SecurityOrchestration|HIPAA') },
          { id: 'gdpr', label: s__('SecurityOrchestration|GDPR') },
          { id: 'fedramp', label: s__('SecurityOrchestration|FedRAMP') },
          { id: 'iso27001', label: s__('SecurityOrchestration|ISO27001') },
        ],
      },
      {
        key: 'businessCriticality',
        type: 'select',
        label: s__('SecurityOrchestration|Business Criticality'),
        options: [
          idAsOption('any'),
          idAsOption('low'),
          idAsOption('medium'),
          idAsOption('high'),
          idAsOption('mission_critical'),
        ],
      },
    ],
  },
  {
    id: 'approval_requirements',
    label: s__('SecurityOrchestration|Approval Requirements'),
    description: s__('SecurityOrchestration|Check approval status and requirements'),
    icon: 'approval',
    fields: [
      {
        key: 'minApprovals',
        type: 'text',
        label: s__('SecurityOrchestration|Minimum Approvals'),
        placeholder: '',
      },
      {
        key: 'requiredGroups',
        type: 'text',
        label: s__('SecurityOrchestration|Required Approver Groups'),
        placeholder: s__('SecurityOrchestration|e.g., security-team, architects'),
      },
      {
        key: 'codeOwnersApproved',
        type: 'toggle',
        label: s__('SecurityOrchestration|Code Owners Approved'),
      },
      {
        key: 'preventSelfApproval',
        type: 'toggle',
        label: s__('SecurityOrchestration|Prevent Self-Approval'),
      },
    ],
  },
  {
    id: 'environment_status',
    label: s__('SecurityOrchestration|Environment Status'),
    description: s__('SecurityOrchestration|Check deployment and environment status'),
    icon: 'deployments',
    fields: [
      {
        key: 'priorEnvironments',
        type: 'text',
        label: s__('SecurityOrchestration|Required Prior Environments'),
        placeholder: s__('SecurityOrchestration|e.g., staging, qa'),
      },
      {
        key: 'requireSuccessful',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Successful Deployment'),
      },
      {
        key: 'minTimeHours',
        type: 'text',
        label: s__('SecurityOrchestration|Minimum Time in Environment (hours)'),
        placeholder: '',
      },
      {
        key: 'requireHealthCheck',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Health Check Pass'),
      },
    ],
  },
  {
    id: 'time_based_conditions',
    label: s__('SecurityOrchestration|Time-Based Conditions'),
    description: s__('SecurityOrchestration|Apply time-based restrictions'),
    icon: 'clock',
    fields: [
      {
        key: 'allowedDays',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Allowed Days'),
        options: [
          { id: 'monday', label: s__('SecurityOrchestration|Monday') },
          { id: 'tuesday', label: s__('SecurityOrchestration|Tuesday') },
          { id: 'wednesday', label: s__('SecurityOrchestration|Wednesday') },
          { id: 'thursday', label: s__('SecurityOrchestration|Thursday') },
          { id: 'friday', label: s__('SecurityOrchestration|Friday') },
          { id: 'saturday', label: s__('SecurityOrchestration|Saturday') },
          { id: 'sunday', label: s__('SecurityOrchestration|Sunday') },
        ],
      },
      {
        key: 'hoursStart',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Hours Start'),
        placeholder: '',
      },
      {
        key: 'hoursEnd',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Hours End'),
        placeholder: '',
      },
      {
        key: 'respectFreeze',
        type: 'toggle',
        label: s__('SecurityOrchestration|Respect Freeze Periods'),
      },
    ],
  },
  {
    id: 'file_change_detection',
    label: s__('SecurityOrchestration|File Change Detection'),
    description: s__('SecurityOrchestration|Detect specific file changes'),
    icon: 'doc-code',
    fields: [
      {
        key: 'filePatterns',
        type: 'text',
        label: s__('SecurityOrchestration|File Patterns'),
        placeholder: s__('SecurityOrchestration|e.g., *.tf, Dockerfile, .gitlab-ci.yml'),
      },
      {
        key: 'sensitivePaths',
        type: 'text',
        label: s__('SecurityOrchestration|Sensitive Paths'),
        placeholder: s__('SecurityOrchestration|e.g., /config/, /secrets/'),
      },
      {
        key: 'maxFiles',
        type: 'text',
        label: s__('SecurityOrchestration|Max Files Changed'),
        placeholder: '',
      },
      {
        key: 'maxLines',
        type: 'text',
        label: s__('SecurityOrchestration|Max Lines Changed'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'license_compliance',
    label: s__('SecurityOrchestration|License Compliance'),
    description: s__('SecurityOrchestration|Check dependency license compliance'),
    icon: 'license',
    fields: [
      {
        key: 'deniedLicenses',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Licenses'),
        placeholder: s__('SecurityOrchestration|e.g., GPL-3.0, AGPL'),
      },
      {
        key: 'approvalLicenses',
        type: 'text',
        label: s__('SecurityOrchestration|Licenses Requiring Approval'),
        placeholder: s__('SecurityOrchestration|e.g., LGPL, MPL'),
      },
      {
        key: 'allowUnknown',
        type: 'toggle',
        label: s__('SecurityOrchestration|Allow Unknown Licenses'),
      },
    ],
  },
  {
    id: 'setting_validation',
    label: s__('SecurityOrchestration|Setting Validation'),
    description: s__('SecurityOrchestration|Validate project/group settings'),
    icon: 'settings',
    fields: [
      {
        key: 'requiredSettings',
        type: 'text',
        label: s__('SecurityOrchestration|Required Settings'),
        placeholder: '',
      },
      {
        key: 'prohibitedSettings',
        type: 'text',
        label: s__('SecurityOrchestration|Prohibited Settings'),
        placeholder: '',
      },
      {
        key: 'allowedVisibility',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Allowed Visibility'),
        options: [idAsOption('private'), idAsOption('internal'), idAsOption('public')],
      },
    ],
  },
  {
    id: 'fix_availability',
    label: s__('SecurityOrchestration|Fix Availability'),
    description: s__(
      'SecurityOrchestration|Filter vulnerabilities based on fix availability and component context',
    ),
    icon: 'settings',
    fields: [
      { key: 'fixAvailable', type: 'toggle', label: s__('SecurityOrchestration|Fix Available') },
      {
        key: 'componentAuthPosture',
        type: 'select',
        label: s__('SecurityOrchestration|Component Auth Posture'),
        options: [idAsOption('any'), idAsOption('none'), idAsOption('weak'), idAsOption('strong')],
      },
      {
        key: 'touchesSensitiveData',
        type: 'toggle',
        label: s__('SecurityOrchestration|Touches Sensitive Data'),
      },
      {
        key: 'scannerTypes',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Scanner Types'),
        options: [
          idAsOption('sast'),
          idAsOption('dependency_scanning'),
          idAsOption('container_scanning'),
          idAsOption('dast'),
        ],
      },
    ],
  },
  {
    id: 'vulnerability_exception',
    label: s__('SecurityOrchestration|Vulnerability Exception'),
    description: s__(
      'SecurityOrchestration|Manage vulnerability snooze and ignore states with time-bound exceptions',
    ),
    icon: 'warning',
    fields: [
      {
        key: 'exceptionType',
        type: 'select',
        label: s__('SecurityOrchestration|Exception Type'),
        options: [idAsOption('snooze'), idAsOption('ignore'), idAsOption('accept_risk')],
      },
      {
        key: 'duration',
        type: 'text',
        label: s__('SecurityOrchestration|Duration (days)'),
        placeholder: '',
      },
      {
        key: 'cveCweList',
        type: 'text',
        label: s__('SecurityOrchestration|CVE/CWE List'),
        placeholder: s__('SecurityOrchestration|e.g., CVE-2021-44228, CWE-79'),
      },
      {
        key: 'requireJustification',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Justification'),
      },
      {
        key: 'maxSeverity',
        type: 'select',
        label: s__('SecurityOrchestration|Max Severity for Exception'),
        options: [
          idAsOption('critical'),
          idAsOption('high'),
          idAsOption('medium'),
          idAsOption('low'),
        ],
      },
      {
        key: 'autoReopenKev',
        type: 'toggle',
        label: s__('SecurityOrchestration|Auto-Reopen if in KEV'),
      },
    ],
  },
  {
    id: 'required_status_check',
    label: s__('SecurityOrchestration|Required Status Check'),
    description: s__(
      'SecurityOrchestration|Require specific external or internal status checks to pass',
    ),
    icon: 'check-circle',
    fields: [
      {
        key: 'requiredChecks',
        type: 'text',
        label: s__('SecurityOrchestration|Required Checks'),
        placeholder: s__(
          'SecurityOrchestration|e.g., sonarqube/quality-gate, security/pen-test-clear',
        ),
      },
      {
        key: 'checkSource',
        type: 'select',
        label: s__('SecurityOrchestration|Check Source'),
        options: [idAsOption('internal'), idAsOption('external'), idAsOption('any')],
      },
      {
        key: 'timeout',
        type: 'text',
        label: s__('SecurityOrchestration|Timeout (minutes)'),
        placeholder: '',
      },
      {
        key: 'allowMergePending',
        type: 'toggle',
        label: s__('SecurityOrchestration|Allow Merge While Pending'),
      },
    ],
  },
  {
    id: 'project_template_compliance',
    label: s__('SecurityOrchestration|Project Template Compliance'),
    description: s__(
      'SecurityOrchestration|Validate project was created from approved template and retains required configuration',
    ),
    icon: 'project',
    fields: [
      {
        key: 'approvedTemplates',
        type: 'text',
        label: s__('SecurityOrchestration|Approved Templates'),
        placeholder: s__(
          'SecurityOrchestration|e.g., internal-service-template, microservice-template',
        ),
      },
      {
        key: 'requiredFiles',
        type: 'text',
        label: s__('SecurityOrchestration|Required Files'),
        placeholder: s__('SecurityOrchestration|e.g., .gitlab-ci.yml, CODEOWNERS, SECURITY.md'),
      },
      {
        key: 'requiredCiIncludes',
        type: 'text',
        label: s__('SecurityOrchestration|Required CI Includes'),
        placeholder: s__('SecurityOrchestration|e.g., templates/security-scans.yml'),
      },
      {
        key: 'requiredTopics',
        type: 'text',
        label: s__('SecurityOrchestration|Required Topics'),
        placeholder: s__('SecurityOrchestration|e.g., production, pci-scope'),
      },
      {
        key: 'requiredFramework',
        type: 'select',
        label: s__('SecurityOrchestration|Required Compliance Framework'),
        options: [
          { id: 'pci_dss', label: s__('SecurityOrchestration|PCI-DSS') },
          { id: 'soc2', label: s__('SecurityOrchestration|SOC2') },
          { id: 'hipaa', label: s__('SecurityOrchestration|HIPAA') },
          { id: 'gdpr', label: s__('SecurityOrchestration|GDPR') },
          { id: 'fedramp', label: s__('SecurityOrchestration|FedRAMP') },
          { id: 'iso27001', label: s__('SecurityOrchestration|ISO27001') },
        ],
      },
    ],
  },
  {
    id: 'change_request_validation',
    label: s__('SecurityOrchestration|Change Request Validation'),
    description: s__(
      'SecurityOrchestration|Validate an associated change request exists and is approved in an external system',
    ),
    icon: 'issue-type-issue',
    fields: [
      {
        key: 'system',
        type: 'select',
        label: s__('SecurityOrchestration|System'),
        options: [
          idAsOption('servicenow'),
          idAsOption('jira'),
          idAsOption('gitlab_issues'),
          idAsOption('custom'),
        ],
      },
      {
        key: 'requireApprovedCr',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Approved CR'),
      },
      {
        key: 'crPattern',
        type: 'text',
        label: s__('SecurityOrchestration|CR Pattern'),
        placeholder: s__('SecurityOrchestration|e.g., CHG[0-9]+, JIRA-[A-Z]+-[0-9]+'),
      },
      {
        key: 'allowedCrTypes',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Allowed CR Types'),
        options: [idAsOption('standard'), idAsOption('emergency'), idAsOption('normal')],
      },
      {
        key: 'validateMaintenanceWindow',
        type: 'toggle',
        label: s__('SecurityOrchestration|Validate Maintenance Window'),
      },
    ],
  },
  {
    id: 'data_classification_check',
    label: s__('SecurityOrchestration|Data Classification Check'),
    description: s__(
      'SecurityOrchestration|Evaluate code and configuration for data handling compliance',
    ),
    icon: 'label',
    fields: [
      {
        key: 'classificationLevel',
        type: 'select',
        label: s__('SecurityOrchestration|Classification Level'),
        options: [
          idAsOption('public'),
          idAsOption('internal'),
          idAsOption('confidential'),
          idAsOption('restricted'),
        ],
      },
      {
        key: 'scanForPii',
        type: 'toggle',
        label: s__('SecurityOrchestration|Scan for PII Patterns'),
      },
      {
        key: 'requireEncryption',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Encryption'),
      },
      {
        key: 'dataResidency',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Allowed Data Residency'),
        options: [
          idAsOption('us-east'),
          idAsOption('us-west'),
          idAsOption('eu-west'),
          idAsOption('eu-central'),
          idAsOption('ap-southeast'),
          idAsOption('ap-northeast'),
        ],
      },
      {
        key: 'requireRetentionPolicy',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Retention Policy'),
      },
    ],
  },
  {
    id: 'dependency_firewall',
    label: s__('SecurityOrchestration|Dependency Firewall'),
    description: s__(
      'SecurityOrchestration|Evaluate dependencies against organizational allowlist/denylist and proxy requirements',
    ),
    icon: 'shield',
    fields: [
      {
        key: 'deniedPackages',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Packages'),
        placeholder: s__('SecurityOrchestration|e.g., event-stream, ua-parser-js'),
      },
      {
        key: 'deniedNamespaces',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Namespaces'),
        placeholder: s__('SecurityOrchestration|e.g., @malicious-org/*'),
      },
      {
        key: 'allowedRegistries',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Registries'),
        placeholder: s__('SecurityOrchestration|e.g., registry.gitlab.com, nexus.internal.com'),
      },
      {
        key: 'requireProxy',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Organizational Proxy'),
      },
      {
        key: 'maxPackageAge',
        type: 'text',
        label: s__('SecurityOrchestration|Max Package Age (days)'),
        placeholder: '',
      },
      {
        key: 'requireSlsa',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require SLSA Provenance'),
      },
    ],
  },
  {
    id: 'malware_detection',
    label: s__('SecurityOrchestration|Malware Detection'),
    description: s__(
      'SecurityOrchestration|Evaluate artifacts and dependencies for known malware signatures',
    ),
    icon: 'bug',
    fields: [
      {
        key: 'scanTargets',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Scan Targets'),
        options: [
          idAsOption('packages'),
          idAsOption('containers'),
          idAsOption('artifacts'),
          idAsOption('binaries'),
        ],
      },
      {
        key: 'confidence',
        type: 'select',
        label: s__('SecurityOrchestration|Detection Confidence'),
        options: [idAsOption('high'), idAsOption('medium'), idAsOption('low')],
      },
      {
        key: 'blockOnAny',
        type: 'toggle',
        label: s__('SecurityOrchestration|Block on Any Detection'),
      },
      {
        key: 'checkTyposquatting',
        type: 'toggle',
        label: s__('SecurityOrchestration|Check Typosquatting'),
      },
    ],
  },
  {
    id: 'sbom_and_provenance',
    label: s__('SecurityOrchestration|SBOM and Provenance'),
    description: s__(
      'SecurityOrchestration|Validate SBOM generation and SLSA provenance attestation requirements',
    ),
    icon: 'list-bulleted',
    fields: [
      { key: 'requireSbom', type: 'toggle', label: s__('SecurityOrchestration|Require SBOM') },
      {
        key: 'sbomFormats',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|SBOM Format'),
        options: [idAsOption('cyclonedx'), idAsOption('spdx')],
      },
      {
        key: 'slsaLevel',
        type: 'select',
        label: s__('SecurityOrchestration|SLSA Level'),
        options: [idAsOption('1'), idAsOption('2'), idAsOption('3'), idAsOption('4')],
      },
      {
        key: 'requireSignedAttestation',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Signed Attestation'),
      },
      {
        key: 'requireReproducible',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Reproducible Build'),
      },
    ],
  },
  {
    id: 'cloud_security_posture',
    label: s__('SecurityOrchestration|Cloud Security Posture'),
    description: s__(
      'SecurityOrchestration|Evaluate cloud infrastructure security posture from CNAPP/CSPM data',
    ),
    icon: 'cloud-gear',
    fields: [
      {
        key: 'dataSource',
        type: 'select',
        label: s__('SecurityOrchestration|Data Source'),
        options: [
          idAsOption('wiz'),
          idAsOption('prisma_cloud'),
          idAsOption('aws_security_hub'),
          idAsOption('gitlab_cnapp'),
          idAsOption('custom'),
        ],
      },
      {
        key: 'minPostureScore',
        type: 'text',
        label: s__('SecurityOrchestration|Min Posture Score (0-100)'),
        placeholder: '',
      },
      {
        key: 'maxCriticalFindings',
        type: 'text',
        label: s__('SecurityOrchestration|Max Critical Findings'),
        placeholder: '',
      },
      {
        key: 'benchmarks',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Required Benchmarks'),
        options: [
          { id: 'cis_aws', label: s__('SecurityOrchestration|CIS AWS') },
          { id: 'cis_gcp', label: s__('SecurityOrchestration|CIS GCP') },
          { id: 'cis_azure', label: s__('SecurityOrchestration|CIS Azure') },
          { id: 'nist_800_53', label: s__('SecurityOrchestration|NIST 800-53') },
          { id: 'soc2', label: s__('SecurityOrchestration|SOC2') },
        ],
      },
      { key: 'alertOnDrift', type: 'toggle', label: s__('SecurityOrchestration|Alert on Drift') },
    ],
  },
  {
    id: 'push_rule_check',
    label: s__('SecurityOrchestration|Push Rule Check'),
    description: s__(
      'SecurityOrchestration|Evaluate commit signing, message format, author restrictions, file size limits',
    ),
    icon: 'commit',
    fields: [
      {
        key: 'requireSignedCommits',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Signed Commits (GPG/SSH)'),
      },
      {
        key: 'commitMessageFormat',
        type: 'select',
        label: s__('SecurityOrchestration|Commit Message Format'),
        options: [
          idAsOption('any'),
          idAsOption('conventional_commits'),
          idAsOption('jira_ticket_prefix'),
          idAsOption('custom_regex'),
        ],
      },
      {
        key: 'customCommitRegex',
        type: 'text',
        label: s__('SecurityOrchestration|Custom Commit Message Regex'),
        placeholder: s__('SecurityOrchestration|e.g., ^feat: .+'),
      },
      {
        key: 'allowedEmailDomains',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Author Email Domains'),
        placeholder: s__('SecurityOrchestration|e.g., @company.com, @contractor.company.com'),
      },
      {
        key: 'branchNaming',
        type: 'text',
        label: s__('SecurityOrchestration|Branch Naming Convention'),
        placeholder: s__('SecurityOrchestration|e.g., ^feature/[a-z0-9-]+$'),
      },
      {
        key: 'maxFileSizeMb',
        type: 'text',
        label: s__('SecurityOrchestration|Max File Size (MB)'),
        placeholder: '',
      },
      {
        key: 'blockSecrets',
        type: 'toggle',
        label: s__('SecurityOrchestration|Block Pushes Containing Secrets'),
      },
    ],
  },
  {
    id: 'required_components',
    label: s__('SecurityOrchestration|Required Components'),
    description: s__(
      'SecurityOrchestration|CI/CD Catalog components that must be present in every pipeline',
    ),
    icon: 'code',
    fields: [
      {
        key: 'components',
        type: 'text',
        label: s__('SecurityOrchestration|Required Components'),
        placeholder: s__('SecurityOrchestration|e.g., gitlab.com/components/sast@3.0'),
      },
      {
        key: 'enforcement',
        type: 'select',
        label: s__('SecurityOrchestration|Enforcement Mode'),
        options: [idAsOption('enforce'), idAsOption('warn')],
      },
      {
        key: 'policyScope',
        type: 'select',
        label: s__('SecurityOrchestration|Policy Scope'),
        options: [
          idAsOption('all_projects'),
          idAsOption('specific_groups'),
          idAsOption('specific_projects'),
          idAsOption('compliance_framework'),
        ],
      },
      {
        key: 'scopeTargets',
        type: 'text',
        label: s__('SecurityOrchestration|Scope Targets'),
        placeholder: s__('SecurityOrchestration|e.g., group/path or framework label'),
      },
    ],
  },
  {
    id: 'allowed_components',
    label: s__('SecurityOrchestration|Allowed Components'),
    description: s__(
      'SecurityOrchestration|CI/CD Catalog components that are permitted for use in pipelines',
    ),
    icon: 'check-circle',
    fields: [
      {
        key: 'components',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Components'),
        placeholder: s__('SecurityOrchestration|e.g., gitlab.com/components/code-quality'),
      },
      {
        key: 'enforcement',
        type: 'select',
        label: s__('SecurityOrchestration|Enforcement Mode'),
        options: [idAsOption('enforce'), idAsOption('warn')],
      },
      {
        key: 'policyScope',
        type: 'select',
        label: s__('SecurityOrchestration|Policy Scope'),
        options: [
          idAsOption('all_projects'),
          idAsOption('specific_groups'),
          idAsOption('specific_projects'),
          idAsOption('compliance_framework'),
        ],
      },
      {
        key: 'scopeTargets',
        type: 'text',
        label: s__('SecurityOrchestration|Scope Targets'),
        placeholder: s__('SecurityOrchestration|e.g., group/path or framework label'),
      },
    ],
  },
  {
    id: 'denied_components',
    label: s__('SecurityOrchestration|Denied Components'),
    description: s__(
      'SecurityOrchestration|CI/CD Catalog components that are blocked from use in pipelines',
    ),
    icon: 'cancel',
    fields: [
      {
        key: 'components',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Components'),
        placeholder: s__('SecurityOrchestration|e.g., gitlab.com/components/unsafe-tool'),
      },
      {
        key: 'enforcement',
        type: 'select',
        label: s__('SecurityOrchestration|Enforcement Mode'),
        options: [idAsOption('enforce'), idAsOption('warn')],
      },
      {
        key: 'policyScope',
        type: 'select',
        label: s__('SecurityOrchestration|Policy Scope'),
        options: [
          idAsOption('all_projects'),
          idAsOption('specific_groups'),
          idAsOption('specific_projects'),
          idAsOption('compliance_framework'),
        ],
      },
      {
        key: 'scopeTargets',
        type: 'text',
        label: s__('SecurityOrchestration|Scope Targets'),
        placeholder: s__('SecurityOrchestration|e.g., group/path or framework label'),
      },
    ],
  },
  {
    id: 'prompt_content_check',
    label: s__('SecurityOrchestration|Prompt Content Check'),
    description: s__(
      'SecurityOrchestration|Scan AI prompt content for secrets, PII, sensitive data, or prohibited topics',
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'scanSecrets',
        type: 'toggle',
        label: s__('SecurityOrchestration|Scan for Secrets (API keys, tokens, passwords)'),
      },
      {
        key: 'scanPii',
        type: 'toggle',
        label: s__('SecurityOrchestration|Scan for PII (emails, SSNs, credit cards)'),
      },
      {
        key: 'blockedTopics',
        type: 'text',
        label: s__('SecurityOrchestration|Blocked Topics/Keywords'),
        placeholder: s__('SecurityOrchestration|e.g., internal-codename, acquisition-target'),
      },
      {
        key: 'maxPromptLength',
        type: 'text',
        label: s__('SecurityOrchestration|Max Prompt Length (chars)'),
        placeholder: '',
      },
      {
        key: 'checkEmbeddedCode',
        type: 'toggle',
        label: s__('SecurityOrchestration|Check Embedded Code Snippets'),
      },
      {
        key: 'sensitiveFilePatterns',
        type: 'text',
        label: s__('SecurityOrchestration|Sensitive File Patterns'),
        placeholder: s__('SecurityOrchestration|e.g., .env, **/secrets/**, **/credentials/**'),
      },
    ],
  },
  {
    id: 'ai_tool_access_control',
    label: s__('SecurityOrchestration|AI Tool Access Control'),
    description: s__(
      'SecurityOrchestration|Control which tools and MCP servers an AI agent can invoke',
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'allowedTools',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Tools'),
        placeholder: s__('SecurityOrchestration|e.g., Read, Glob, Grep'),
      },
      {
        key: 'deniedTools',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Tools'),
        placeholder: s__('SecurityOrchestration|e.g., Bash, Task, Write'),
      },
      {
        key: 'requireApprovalFor',
        type: 'text',
        label: s__('SecurityOrchestration|Require Approval For'),
        placeholder: s__('SecurityOrchestration|e.g., Bash:rm, Bash:git push --force'),
      },
      {
        key: 'allowedMcpServers',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed MCP Servers'),
        placeholder: s__('SecurityOrchestration|e.g., filesystem, gitlab'),
      },
      {
        key: 'deniedMcpServers',
        type: 'text',
        label: s__('SecurityOrchestration|Denied MCP Servers'),
        placeholder: s__('SecurityOrchestration|e.g., custom_webhook, external_api'),
      },
      {
        key: 'scopeToProject',
        type: 'toggle',
        label: s__('SecurityOrchestration|Scope to Current Project Only'),
      },
    ],
  },
  {
    id: 'ai_file_access_control',
    label: s__('SecurityOrchestration|AI File Access Control'),
    description: s__(
      'SecurityOrchestration|Control which files and paths an AI agent can read or modify',
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'allowedPaths',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Paths'),
        placeholder: s__('SecurityOrchestration|e.g., src/**, tests/**, docs/**'),
      },
      {
        key: 'deniedPaths',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Paths'),
        placeholder: s__('SecurityOrchestration|e.g., **/.env, **/secrets/**, **/credentials/**'),
      },
      {
        key: 'autoDenySecretFiles',
        type: 'toggle',
        label: s__('SecurityOrchestration|Auto-Deny Known Secret Files'),
      },
      {
        key: 'readOnlyPaths',
        type: 'text',
        label: s__('SecurityOrchestration|Read-Only Paths'),
        placeholder: s__('SecurityOrchestration|e.g., config/**, infrastructure/**'),
      },
      {
        key: 'maxFileSizeKb',
        type: 'text',
        label: s__('SecurityOrchestration|Max File Size to Process (KB)'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'ai_spend_usage_limit',
    label: s__('SecurityOrchestration|AI Spend & Usage Limit'),
    description: s__('SecurityOrchestration|Enforce cost and usage limits on AI agent operations'),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'maxSpendUsd',
        type: 'text',
        label: s__('SecurityOrchestration|Max Spend (USD)'),
        placeholder: '',
      },
      {
        key: 'maxInputTokens',
        type: 'text',
        label: s__('SecurityOrchestration|Max Input Tokens'),
        placeholder: '',
      },
      {
        key: 'maxOutputTokens',
        type: 'text',
        label: s__('SecurityOrchestration|Max Output Tokens'),
        placeholder: '',
      },
      {
        key: 'maxTurns',
        type: 'text',
        label: s__('SecurityOrchestration|Max Conversation Turns'),
        placeholder: '',
      },
      {
        key: 'timePeriod',
        type: 'select',
        label: s__('SecurityOrchestration|Time Period'),
        options: [
          idAsOption('per_session'),
          idAsOption('per_hour'),
          idAsOption('per_day'),
          idAsOption('per_month'),
        ],
      },
      {
        key: 'enforcement',
        type: 'select',
        label: s__('SecurityOrchestration|Enforcement'),
        options: [idAsOption('fail_fast'), idAsOption('warn_then_block'), idAsOption('post_hoc')],
      },
    ],
  },
  {
    id: 'ai_model_allowlist',
    label: s__('SecurityOrchestration|AI Model Allowlist'),
    description: s__(
      'SecurityOrchestration|Restrict which AI models and providers can be used within the organization',
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'allowedModels',
        type: 'text',
        label: s__('SecurityOrchestration|Allowed Models'),
        placeholder: s__('SecurityOrchestration|e.g., claude-sonnet-4-20250514, gpt-4o'),
      },
      {
        key: 'deniedModels',
        type: 'text',
        label: s__('SecurityOrchestration|Denied Models'),
        placeholder: s__('SecurityOrchestration|e.g., gpt-3.5-turbo, open-source-uncensored'),
      },
      {
        key: 'allowedProviders',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Allowed Providers'),
        options: [
          idAsOption('gitlab'),
          idAsOption('anthropic'),
          idAsOption('openai'),
          idAsOption('google'),
          idAsOption('mistral'),
          idAsOption('self_hosted'),
        ],
      },
      {
        key: 'requireSelfHosted',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Self-Hosted Models Only'),
      },
      {
        key: 'requireDataResidency',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Data Residency Compliance'),
      },
    ],
  },
];
