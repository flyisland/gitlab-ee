import { s__ } from '~/locale';
import { idAsOption } from './helpers';

export const ACTION_TYPES = [
  {
    id: 'block',
    label: s__('SecurityOrchestration|Block'),
    description: s__('SecurityOrchestration|Block the action from proceeding'),
    icon: 'cancel',
    fields: [
      {
        key: 'message',
        type: 'textarea',
        label: s__('SecurityOrchestration|Block Message'),
        placeholder: s__('SecurityOrchestration|Explain why this is blocked...'),
      },
      {
        key: 'allowOverride',
        type: 'toggle',
        label: s__('SecurityOrchestration|Allow Override with Approval'),
      },
      {
        key: 'overrideApprovers',
        type: 'text',
        label: s__('SecurityOrchestration|Override Approver Groups'),
        placeholder: s__('SecurityOrchestration|e.g., security-leads'),
      },
    ],
  },
  {
    id: 'warn',
    label: s__('SecurityOrchestration|Warn'),
    description: s__('SecurityOrchestration|Display a warning but allow proceeding'),
    icon: 'warning',
    fields: [
      {
        key: 'message',
        type: 'textarea',
        label: s__('SecurityOrchestration|Warning Message'),
        placeholder: s__('SecurityOrchestration|Warning message to display...'),
      },
      {
        key: 'requireAck',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Acknowledgment'),
      },
      {
        key: 'escalateAfterDays',
        type: 'text',
        label: s__('SecurityOrchestration|Escalate to Block After (days)'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'require_approval',
    label: s__('SecurityOrchestration|Require Approval'),
    description: s__('SecurityOrchestration|Require additional approvals'),
    icon: 'approval',
    fields: [
      {
        key: 'approverGroups',
        type: 'text',
        label: s__('SecurityOrchestration|Required Approver Groups'),
        placeholder: s__('SecurityOrchestration|e.g., security-team, compliance'),
      },
      {
        key: 'approvalCount',
        type: 'text',
        label: s__('SecurityOrchestration|Required Approval Count'),
        placeholder: '',
      },
      {
        key: 'requestMessage',
        type: 'textarea',
        label: s__('SecurityOrchestration|Approval Request Message'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'send_notification',
    label: s__('SecurityOrchestration|Send Notification'),
    description: s__('SecurityOrchestration|Send notifications to teams or individuals'),
    icon: 'notifications',
    fields: [
      {
        key: 'channels',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Notification Channels'),
        options: [
          idAsOption('email'),
          idAsOption('slack'),
          idAsOption('teams'),
          idAsOption('webhook'),
        ],
      },
      {
        key: 'recipients',
        type: 'text',
        label: s__('SecurityOrchestration|Recipients'),
        placeholder: s__('SecurityOrchestration|e.g., @security-team, user@example.com'),
      },
      {
        key: 'message',
        type: 'textarea',
        label: s__('SecurityOrchestration|Notification Message'),
        placeholder: '',
      },
      {
        key: 'includePolicyDetails',
        type: 'toggle',
        label: s__('SecurityOrchestration|Include Policy Details'),
      },
    ],
  },
  {
    id: 'create_issue',
    label: s__('SecurityOrchestration|Create Issue'),
    description: s__('SecurityOrchestration|Automatically create a tracking issue'),
    icon: 'issue-type-issue',
    fields: [
      {
        key: 'targetProject',
        type: 'text',
        label: s__('SecurityOrchestration|Target Project'),
        placeholder: s__('SecurityOrchestration|Project path or ID'),
      },
      {
        key: 'titleTemplate',
        type: 'text',
        label: s__('SecurityOrchestration|Issue Title Template'),
        placeholder: '',
      },
      {
        key: 'descriptionTemplate',
        type: 'textarea',
        label: s__('SecurityOrchestration|Description Template'),
        placeholder: '',
      },
      { key: 'labels', type: 'text', label: s__('SecurityOrchestration|Labels'), placeholder: '' },
      {
        key: 'assignees',
        type: 'text',
        label: s__('SecurityOrchestration|Assignees'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'add_labels',
    label: s__('SecurityOrchestration|Add Labels'),
    description: s__('SecurityOrchestration|Add labels to the merge request or issue'),
    icon: 'label',
    fields: [
      {
        key: 'labels',
        type: 'text',
        label: s__('SecurityOrchestration|Labels to Add'),
        placeholder: s__(
          'SecurityOrchestration|e.g., needs-security-review, compliance-check-failed',
        ),
      },
    ],
  },
  {
    id: 'add_comment',
    label: s__('SecurityOrchestration|Add Comment'),
    description: s__('SecurityOrchestration|Add a comment with policy evaluation details'),
    icon: 'comment',
    fields: [
      {
        key: 'template',
        type: 'textarea',
        label: s__('SecurityOrchestration|Comment Template'),
        placeholder: '',
      },
      {
        key: 'includeFindings',
        type: 'toggle',
        label: s__('SecurityOrchestration|Include Detailed Findings'),
      },
      {
        key: 'mentionAuthor',
        type: 'toggle',
        label: s__('SecurityOrchestration|Mention MR Author'),
      },
    ],
  },
  {
    id: 'require_security_scan',
    label: s__('SecurityOrchestration|Require Security Scan'),
    description: s__('SecurityOrchestration|Ensure specific security scans are executed'),
    icon: 'shield',
    fields: [
      {
        key: 'scanTypes',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Required Scan Types'),
        options: [
          idAsOption('sast'),
          idAsOption('dast'),
          idAsOption('dependency_scanning'),
          idAsOption('secret_detection'),
          idAsOption('container_scanning'),
          idAsOption('iac_scanning'),
        ],
      },
      {
        key: 'injectIfMissing',
        type: 'toggle',
        label: s__('SecurityOrchestration|Inject Jobs if Missing'),
      },
    ],
  },
  {
    id: 'auto_approve',
    label: s__('SecurityOrchestration|Auto-Approve'),
    description: s__('SecurityOrchestration|Automatically approve if all conditions pass'),
    icon: 'check-circle',
    fields: [
      {
        key: 'comment',
        type: 'textarea',
        label: s__('SecurityOrchestration|Approval Comment'),
        placeholder: '',
      },
      {
        key: 'includeConditionsSummary',
        type: 'toggle',
        label: s__('SecurityOrchestration|Include Conditions Summary'),
      },
    ],
  },
  {
    id: 'agentic_remediation',
    label: s__('SecurityOrchestration|Agentic Remediation'),
    description: s__(
      'SecurityOrchestration|Deploy AI security agent to create fix MRs with code suggestions',
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'agentType',
        type: 'select',
        label: s__('SecurityOrchestration|Agent Type'),
        options: [
          idAsOption('security_analyst'),
          idAsOption('code_fix'),
          idAsOption('full_remediation'),
        ],
      },
      {
        key: 'mrStrategy',
        type: 'select',
        label: s__('SecurityOrchestration|MR Strategy'),
        options: [
          idAsOption('one_per_vuln'),
          idAsOption('grouped_by_component'),
          idAsOption('grouped_by_severity'),
        ],
      },
      {
        key: 'targetBranch',
        type: 'text',
        label: s__('SecurityOrchestration|Target Branch'),
        placeholder: s__('SecurityOrchestration|e.g., main'),
      },
      {
        key: 'mrReviewers',
        type: 'text',
        label: s__('SecurityOrchestration|MR Reviewers'),
        placeholder: s__('SecurityOrchestration|e.g., @security-team, @dev-lead'),
      },
      {
        key: 'reviewSlaHours',
        type: 'text',
        label: s__('SecurityOrchestration|Review SLA (hours)'),
        placeholder: '',
      },
      {
        key: 'autoMerge',
        type: 'toggle',
        label: s__('SecurityOrchestration|Auto-Merge When Approved'),
      },
      {
        key: 'includeTestSuggestions',
        type: 'toggle',
        label: s__('SecurityOrchestration|Include Test Suggestions'),
      },
      {
        key: 'maxMrs',
        type: 'text',
        label: s__('SecurityOrchestration|Max MRs Per Execution'),
        placeholder: '',
      },
      { key: 'dryRun', type: 'toggle', label: s__('SecurityOrchestration|Dry Run (Preview Only)') },
    ],
  },
  {
    id: 'log_to_audit_trail',
    label: s__('SecurityOrchestration|Log to Audit Trail'),
    description: s__(
      'SecurityOrchestration|Record policy evaluation decision to audit log without blocking',
    ),
    icon: 'doc-text',
    fields: [
      {
        key: 'logLevel',
        type: 'select',
        label: s__('SecurityOrchestration|Log Level'),
        options: [idAsOption('info'), idAsOption('warn'), idAsOption('error')],
      },
      {
        key: 'includeFullContext',
        type: 'toggle',
        label: s__('SecurityOrchestration|Include Full Context'),
      },
      {
        key: 'retentionDays',
        type: 'text',
        label: s__('SecurityOrchestration|Retention (days)'),
        placeholder: '',
      },
      {
        key: 'exportTarget',
        type: 'select',
        label: s__('SecurityOrchestration|Export Target'),
        options: [
          idAsOption('gitlab_audit_events'),
          idAsOption('siem'),
          idAsOption('s3'),
          idAsOption('splunk'),
        ],
      },
    ],
  },
  {
    id: 'enforce_revert_setting',
    label: s__('SecurityOrchestration|Enforce/Revert Setting'),
    description: s__(
      'SecurityOrchestration|Automatically revert a project/group setting to its compliant value',
    ),
    icon: 'settings',
    fields: [
      {
        key: 'settingsToEnforce',
        type: 'text',
        label: s__('SecurityOrchestration|Settings to Enforce'),
        placeholder: '',
      },
      {
        key: 'revertImmediately',
        type: 'toggle',
        label: s__('SecurityOrchestration|Revert Immediately'),
      },
      {
        key: 'notifyOnRevert',
        type: 'toggle',
        label: s__('SecurityOrchestration|Notify on Revert'),
      },
      {
        key: 'gracePeriodHours',
        type: 'text',
        label: s__('SecurityOrchestration|Grace Period (hours)'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'apply_project_template',
    label: s__('SecurityOrchestration|Apply Project Template'),
    description: s__(
      'SecurityOrchestration|Apply a project template or configuration baseline to a newly created project',
    ),
    icon: 'project',
    fields: [
      {
        key: 'templateId',
        type: 'text',
        label: s__('SecurityOrchestration|Template ID'),
        placeholder: s__('SecurityOrchestration|Project template to apply'),
      },
      {
        key: 'applyCiConfig',
        type: 'toggle',
        label: s__('SecurityOrchestration|Apply CI/CD Config'),
      },
      {
        key: 'complianceFramework',
        type: 'select',
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
        key: 'setBranchProtection',
        type: 'toggle',
        label: s__('SecurityOrchestration|Set Branch Protection'),
      },
      {
        key: 'requiredFiles',
        type: 'text',
        label: s__('SecurityOrchestration|Required Files'),
        placeholder: s__('SecurityOrchestration|e.g., CODEOWNERS, .gitlab-ci.yml'),
      },
    ],
  },
  {
    id: 'snooze_vulnerability',
    label: s__('SecurityOrchestration|Snooze Vulnerability'),
    description: s__(
      'SecurityOrchestration|Temporarily suppress a vulnerability finding for a defined duration',
    ),
    icon: 'clock',
    fields: [
      {
        key: 'duration',
        type: 'text',
        label: s__('SecurityOrchestration|Duration (days)'),
        placeholder: '',
      },
      {
        key: 'reason',
        type: 'select',
        label: s__('SecurityOrchestration|Reason'),
        options: [
          idAsOption('false_positive'),
          idAsOption('accepted_risk'),
          idAsOption('mitigated'),
          idAsOption('pending_fix'),
          idAsOption('not_applicable'),
        ],
      },
      {
        key: 'requireApproval',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Approval'),
      },
      {
        key: 'autoReopenOnExpiry',
        type: 'toggle',
        label: s__('SecurityOrchestration|Auto-Reopen on Expiry'),
      },
      {
        key: 'maxSnoozeCount',
        type: 'text',
        label: s__('SecurityOrchestration|Max Snooze Count'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'set_due_date_sla',
    label: s__('SecurityOrchestration|Set Due Date (SLA)'),
    description: s__(
      'SecurityOrchestration|Assign a remediation due date to vulnerabilities based on an SLA matrix',
    ),
    icon: 'clock',
    fields: [
      { key: 'slaMatrix', type: 'sla_matrix', label: s__('SecurityOrchestration|SLA Matrix') },
      {
        key: 'slaClockStarts',
        type: 'select',
        label: s__('SecurityOrchestration|SLA Clock Starts'),
        options: [
          idAsOption('detection_date'),
          idAsOption('fix_available_date'),
          idAsOption('confirmation_date'),
        ],
      },
      {
        key: 'policySourceLabel',
        type: 'text',
        label: s__('SecurityOrchestration|Policy Source Label'),
        placeholder: s__('SecurityOrchestration|e.g., Standard Enterprise SLA'),
      },
      {
        key: 'applyToExisting',
        type: 'toggle',
        label: s__('SecurityOrchestration|Apply to Existing Open Vulns'),
      },
    ],
  },
  {
    id: 'create_external_ticket',
    label: s__('SecurityOrchestration|Create External Ticket'),
    description: s__(
      'SecurityOrchestration|Create a ticket in an external system (ServiceNow, Jira, PagerDuty)',
    ),
    icon: 'external-link',
    fields: [
      {
        key: 'system',
        type: 'select',
        label: s__('SecurityOrchestration|System'),
        options: [
          idAsOption('servicenow'),
          idAsOption('jira'),
          idAsOption('pagerduty'),
          idAsOption('opsgenie'),
        ],
      },
      {
        key: 'ticketType',
        type: 'select',
        label: s__('SecurityOrchestration|Ticket Type'),
        options: [
          idAsOption('incident'),
          idAsOption('change_request'),
          idAsOption('problem'),
          idAsOption('task'),
        ],
      },
      {
        key: 'priority',
        type: 'select',
        label: s__('SecurityOrchestration|Priority'),
        options: [
          idAsOption('critical'),
          idAsOption('high'),
          idAsOption('medium'),
          idAsOption('low'),
        ],
      },
      {
        key: 'titleTemplate',
        type: 'text',
        label: s__('SecurityOrchestration|Title Template'),
        placeholder: '',
      },
      {
        key: 'descriptionTemplate',
        type: 'textarea',
        label: s__('SecurityOrchestration|Description Template'),
        placeholder: '',
      },
      {
        key: 'assignmentGroup',
        type: 'text',
        label: s__('SecurityOrchestration|Assignment Group'),
        placeholder: s__('SecurityOrchestration|Target team/group'),
      },
    ],
  },
  {
    id: 'generate_compliance_evidence',
    label: s__('SecurityOrchestration|Generate Compliance Evidence'),
    description: s__(
      'SecurityOrchestration|Automatically generate and store compliance evidence artifacts',
    ),
    icon: 'doc-text',
    fields: [
      {
        key: 'evidenceTypes',
        type: 'multi_badge',
        label: s__('SecurityOrchestration|Evidence Type'),
        options: [
          idAsOption('policy_evaluation'),
          idAsOption('scan_results'),
          idAsOption('approval_chain'),
          idAsOption('deployment_log'),
          idAsOption('configuration_snapshot'),
        ],
      },
      {
        key: 'format',
        type: 'select',
        label: s__('SecurityOrchestration|Format'),
        options: [idAsOption('json'), idAsOption('pdf'), idAsOption('csv')],
      },
      {
        key: 'storageLocation',
        type: 'text',
        label: s__('SecurityOrchestration|Storage Location'),
        placeholder: s__('SecurityOrchestration|Where to store evidence'),
      },
      {
        key: 'frameworkTags',
        type: 'text',
        label: s__('SecurityOrchestration|Framework Tags'),
        placeholder: s__('SecurityOrchestration|e.g., SOC2, PCI-DSS, FedRAMP'),
      },
      {
        key: 'retentionYears',
        type: 'text',
        label: s__('SecurityOrchestration|Retention (years)'),
        placeholder: '',
      },
    ],
  },
  {
    id: 'fail_pipeline',
    label: s__('SecurityOrchestration|Fail Pipeline'),
    description: s__(
      'SecurityOrchestration|Explicitly fail a running pipeline with a policy violation status',
    ),
    icon: 'cancel',
    fields: [
      {
        key: 'exitCode',
        type: 'text',
        label: s__('SecurityOrchestration|Exit Code'),
        placeholder: '',
      },
      {
        key: 'failureReason',
        type: 'text',
        label: s__('SecurityOrchestration|Failure Reason'),
        placeholder: s__('SecurityOrchestration|Reason for pipeline failure'),
      },
      { key: 'allowRetry', type: 'toggle', label: s__('SecurityOrchestration|Allow Retry') },
      {
        key: 'markVulnsBlocked',
        type: 'toggle',
        label: s__('SecurityOrchestration|Mark Vulns as Blocked'),
      },
    ],
  },
  {
    id: 'redact_ai_prompt',
    label: s__('SecurityOrchestration|Redact AI Prompt'),
    description: s__(
      'SecurityOrchestration|Redact sensitive content from AI prompt before sending to the model',
    ),
    icon: 'tanuki-ai',
    fields: [
      { key: 'redactSecrets', type: 'toggle', label: s__('SecurityOrchestration|Redact Secrets') },
      { key: 'redactPii', type: 'toggle', label: s__('SecurityOrchestration|Redact PII') },
      {
        key: 'sensitiveCodePaths',
        type: 'text',
        label: s__('SecurityOrchestration|Redact Code from Sensitive Paths'),
        placeholder: s__('SecurityOrchestration|e.g., **/secrets/**, **/.env'),
      },
      {
        key: 'replacementStrategy',
        type: 'select',
        label: s__('SecurityOrchestration|Replacement Strategy'),
        options: [idAsOption('mask'), idAsOption('placeholder'), idAsOption('reject')],
      },
      {
        key: 'notifyUser',
        type: 'toggle',
        label: s__('SecurityOrchestration|Notify User of Redaction'),
      },
    ],
  },
  {
    id: 'restrict_ai_agent',
    label: s__('SecurityOrchestration|Restrict AI Agent'),
    description: s__(
      "SecurityOrchestration|Dynamically restrict an AI agent's capabilities when policy is violated",
    ),
    icon: 'tanuki-ai',
    fields: [
      {
        key: 'revokeTools',
        type: 'text',
        label: s__('SecurityOrchestration|Revoke Tools'),
        placeholder: s__('SecurityOrchestration|e.g., Bash, Write, Task'),
      },
      {
        key: 'downgradeReadOnly',
        type: 'toggle',
        label: s__('SecurityOrchestration|Downgrade to Read-Only'),
      },
      {
        key: 'requireHumanApproval',
        type: 'toggle',
        label: s__('SecurityOrchestration|Require Human Approval for Actions'),
      },
      {
        key: 'terminateSession',
        type: 'toggle',
        label: s__('SecurityOrchestration|Terminate Agent Session'),
      },
      {
        key: 'cooldownMinutes',
        type: 'text',
        label: s__('SecurityOrchestration|Cooldown Period (minutes)'),
        placeholder: '',
      },
    ],
  },
];
