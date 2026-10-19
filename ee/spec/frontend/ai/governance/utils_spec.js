import { formatAgentType, formatSessionSource } from 'ee/ai/governance/utils';

describe('formatAgentType', () => {
  it.each([
    ['claude-code', 'Claude Code'],
    ['cursor', 'Cursor'],
    ['codex', 'Codex'],
  ])('names the %s agent type by its product name', (agentType, name) => {
    expect(formatAgentType(agentType)).toBe(name);
  });
});

describe('formatSessionSource', () => {
  it.each([
    ['cursor', 'Cursor (glab)'],
    ['codex', 'Codex (glab)'],
    ['claude-code', 'Claude Code (glab)'],
  ])('names a glab session with the %s agent type after its agent', (agentType, label) => {
    expect(formatSessionSource({ source: 'CLAUDE_CODE_GLAB', agentType })).toBe(label);
  });

  it('keeps the glab source label when the session has no agent type', () => {
    expect(formatSessionSource({ source: 'CLAUDE_CODE_GLAB', agentType: null })).toBe(
      'Claude Code (glab)',
    );
  });

  it.each([
    ['GITLAB_DUO', 'GitLab Duo'],
    ['CLAUDE_CODE_COMPLIANCE_API', 'Claude Code (Compliance API)'],
  ])('labels a %s session by its source alone', (source, label) => {
    expect(formatSessionSource({ source, agentType: 'cursor' })).toBe(label);
  });

  it('returns undefined for an unknown source or a missing session', () => {
    expect(formatSessionSource({ source: 'SOMETHING_NEW', agentType: 'cursor' })).toBeUndefined();
    expect(formatSessionSource(null)).toBeUndefined();
  });
});
