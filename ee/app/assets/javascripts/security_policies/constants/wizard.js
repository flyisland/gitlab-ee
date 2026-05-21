import { s__ } from '~/locale';

export const WIZARD_STEPS = [
  { id: 1, label: s__('SecurityOrchestration|Details & Scope') },
  { id: 2, label: s__('SecurityOrchestration|Trigger') },
  { id: 3, label: s__('SecurityOrchestration|Rules') },
  { id: 4, label: s__('SecurityOrchestration|Actions') },
];

export const SUMMARY_TILES = [
  {
    id: 'global_security',
    title: s__('SecurityOrchestration|Global Security Policies'),
    icon: 'shield',
    actionLabel: s__('SecurityOrchestration|View Details'),
  },
  {
    id: 'compliance_governance',
    title: s__('SecurityOrchestration|Compliance & Governance'),
    icon: 'check-circle',
    actionLabel: s__('SecurityOrchestration|View Details'),
  },
  {
    id: 'supply_chain',
    title: s__('SecurityOrchestration|Supply Chain Security'),
    icon: 'package',
    actionLabel: s__('SecurityOrchestration|Activate Security'),
  },
  {
    id: 'ai_governance',
    title: s__('SecurityOrchestration|AI Governance Guardrails'),
    icon: 'tanuki-ai',
    actionLabel: s__('SecurityOrchestration|Activate Details'),
  },
  {
    id: 'tams_compliance',
    title: s__('SecurityOrchestration|TAMS/IT Compliance'),
    icon: 'doc-text',
    actionLabel: s__('SecurityOrchestration|View Results'),
  },
  {
    id: 'vulnerability_management',
    title: s__('SecurityOrchestration|Vulnerability & Management'),
    icon: 'warning-solid',
    actionLabel: s__('SecurityOrchestration|View Details'),
  },
];
