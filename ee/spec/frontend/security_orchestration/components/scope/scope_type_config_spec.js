import ComplianceFrameworksToggleList from 'ee/security_orchestration/components/scope/compliance_frameworks_toggle_list.vue';
import ProjectsToggleList from 'ee/security_orchestration/components/scope/projects_toggle_list.vue';
import GroupsToggleList from 'ee/security_orchestration/components/scope/groups_toggle_list.vue';
import ScopeDefaultLabel from 'ee/security_orchestration/components/scope/scope_default_label.vue';
import { resolveScopeType } from 'ee/security_orchestration/components/scope/scope_type_config';

const ctx = { isGroup: true, isInstanceLevel: false, linkedSppItems: [] };

describe('resolveScopeType', () => {
  it.each`
    description                                | policyScope                                                                               | expectedComponent
    ${'compliance frameworks'}                 | ${{ complianceFrameworks: { nodes: [{ id: 1 }] } }}                                       | ${ComplianceFrameworksToggleList}
    ${'includingGroups only'}                  | ${{ includingGroups: { nodes: [{ id: 1 }] } }}                                            | ${GroupsToggleList}
    ${'compound (groups + excl projects)'}     | ${{ includingGroups: { nodes: [{ id: 1 }] }, excludingProjects: { nodes: [{ id: 2 }] } }} | ${GroupsToggleList}
    ${'compound (groups + incl projects)'}     | ${{ includingGroups: { nodes: [{ id: 1 }] }, includingProjects: { nodes: [{ id: 2 }] } }} | ${GroupsToggleList}
    ${'includingProjects'}                     | ${{ includingProjects: { nodes: [{ id: 1 }] } }}                                          | ${ProjectsToggleList}
    ${'excludingProjects with ids'}            | ${{ excludingProjects: { nodes: [{ id: 1 }] } }}                                          | ${ProjectsToggleList}
    ${'excludingPersonalProjects'}             | ${{ excludingPersonalProjects: true }}                                                    | ${ProjectsToggleList}
    ${'empty compliance frameworks nodes'}     | ${{ complianceFrameworks: { nodes: [] } }}                                                | ${ScopeDefaultLabel}
    ${'null-only nodes filtered to empty'}     | ${{ complianceFrameworks: { nodes: [null] } }}                                            | ${ScopeDefaultLabel}
    ${'empty groups + real excludingProjects'} | ${{ includingGroups: { nodes: [] }, excludingProjects: { nodes: [{ id: 1 }] } }}          | ${ProjectsToggleList}
    ${'empty includingProjects nodes'}         | ${{ includingProjects: { nodes: [] } }}                                                   | ${ScopeDefaultLabel}
    ${'no scope data'}                         | ${{}}                                                                                     | ${ScopeDefaultLabel}
    ${'null'}                                  | ${null}                                                                                   | ${ScopeDefaultLabel}
  `('$description → correct component (drawer)', ({ policyScope, expectedComponent }) => {
    expect(resolveScopeType(policyScope, 'drawer', ctx).component).toBe(expectedComponent);
  });

  it('compound: includingGroups entry receives excludingProjects in props', () => {
    const scope = {
      includingGroups: { nodes: [{ id: 1 }] },
      excludingProjects: { nodes: [{ id: 2 }] },
    };
    const { props } = resolveScopeType(scope, 'drawer', ctx);
    expect(props.groups).toEqual([{ id: 1 }]);
    expect(props.projects).toEqual([{ id: 2 }]);
  });

  it('list variant adds labelsToShow: 2 for compliance frameworks', () => {
    const scope = { complianceFrameworks: { nodes: [{ id: 1 }] } };
    expect(resolveScopeType(scope, 'list', ctx).props.labelsToShow).toBe(2);
  });

  it('drawer variant does not add labelsToShow for compliance frameworks', () => {
    const scope = { complianceFrameworks: { nodes: [{ id: 1 }] } };
    expect(resolveScopeType(scope, 'drawer', ctx).props.labelsToShow).toBeUndefined();
  });

  it('excludingPersonalProjects sets excludingPersonalProjects=true, projects=[]', () => {
    const scope = { excludingPersonalProjects: true };
    const { props } = resolveScopeType(scope, 'drawer', ctx);
    expect(props.excludingPersonalProjects).toBe(true);
    expect(props.projects).toEqual([]);
  });

  it('passes isInstanceLevel to ProjectsToggleList', () => {
    const scope = { includingProjects: { nodes: [{ id: 1 }] } };
    const { props } = resolveScopeType(scope, 'drawer', { ...ctx, isInstanceLevel: true });
    expect(props.isInstanceLevel).toBe(true);
  });

  describe('list variant props', () => {
    it('includingGroups list passes inlineList and isLink', () => {
      const scope = { includingGroups: { nodes: [{ id: 1 }] } };
      const { props } = resolveScopeType(scope, 'list', ctx);
      expect(props.inlineList).toBe(true);
      expect(props.isLink).toBe(true);
      expect(props.groups).toEqual([{ id: 1 }]);
    });

    it('includingProjects list passes inlineList, bulletStyle, projectsToShow', () => {
      const scope = { includingProjects: { nodes: [{ id: 1 }] } };
      const { props } = resolveScopeType(scope, 'list', ctx);
      expect(props.inlineList).toBe(true);
      expect(props.bulletStyle).toBe(false);
      expect(props.projectsToShow).toBe(2);
      expect(props.including).toBe(true);
      expect(props.excludingPersonalProjects).toBe(false);
    });

    it('excludingProjects list passes inlineList, bulletStyle, projectsToShow', () => {
      const scope = { excludingProjects: { nodes: [{ id: 1 }] } };
      const { props } = resolveScopeType(scope, 'list', ctx);
      expect(props.inlineList).toBe(true);
      expect(props.bulletStyle).toBe(false);
      expect(props.projectsToShow).toBe(2);
      expect(props.including).toBe(false);
      expect(props.excludingPersonalProjects).toBe(false);
    });
  });

  it('throws on unknown variant', () => {
    const scope = { complianceFrameworks: { nodes: [{ id: 1 }] } };
    expect(() => resolveScopeType(scope, 'drwer', ctx)).toThrow(/Unknown scope variant/);
  });
});
