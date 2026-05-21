import ComplianceFrameworksToggleList from './compliance_frameworks_toggle_list.vue';
import ProjectsToggleList from './projects_toggle_list.vue';
import GroupsToggleList from './groups_toggle_list.vue';
import ScopeDefaultLabel from './scope_default_label.vue';

const nodesOf = (obj) => obj?.nodes?.filter(Boolean) ?? [];

const VARIANT_TO_PROPS_KEY = { drawer: 'drawerProps', list: 'listProps' };

// Ordered — first matching predicate wins.
// includingGroups is checked before excludingProjects so the compound case
// (includingGroups + excludingProjects coexisting) routes to GroupsToggleList automatically.
// To add a new scope type: insert one entry. No other files change.
export const SCOPE_TYPE_CONFIG = [
  {
    key: 'complianceFrameworks',
    predicate: (scope) => nodesOf(scope?.complianceFrameworks).length > 0,
    component: ComplianceFrameworksToggleList,
    drawerProps: (scope) => ({
      complianceFrameworks: nodesOf(scope.complianceFrameworks),
    }),
    listProps: (scope) => ({
      complianceFrameworks: nodesOf(scope.complianceFrameworks),
      labelsToShow: 2,
    }),
  },
  {
    key: 'includingGroups',
    // Subsumes excludingProjects when present — compound case handled via priority ordering.
    predicate: (scope) => nodesOf(scope?.includingGroups).length > 0,
    component: GroupsToggleList,
    drawerProps: (scope, { isGroup }) => ({
      isLink: isGroup,
      groups: nodesOf(scope.includingGroups),
      projects: nodesOf(scope.excludingProjects),
      excludingPersonalProjects: Boolean(scope.excludingPersonalProjects),
    }),
    listProps: (scope, { isGroup }) => ({
      inlineList: true,
      isLink: isGroup,
      groups: nodesOf(scope.includingGroups),
      projects: nodesOf(scope.excludingProjects),
      excludingPersonalProjects: Boolean(scope.excludingPersonalProjects),
    }),
  },
  {
    key: 'includingProjects',
    predicate: (scope) => nodesOf(scope?.includingProjects).length > 0,
    component: ProjectsToggleList,
    drawerProps: (scope, { isGroup, isInstanceLevel }) => ({
      isGroup,
      isInstanceLevel,
      including: true,
      projects: nodesOf(scope.includingProjects),
      excludingPersonalProjects: false,
    }),
    listProps: (scope, { isGroup, isInstanceLevel }) => ({
      isGroup,
      isInstanceLevel,
      inlineList: true,
      bulletStyle: false,
      projectsToShow: 2,
      including: true,
      projects: nodesOf(scope.includingProjects),
      excludingPersonalProjects: false,
    }),
  },
  {
    key: 'excludingProjects',
    // Only reached when includingGroups is absent (checked above).
    predicate: (scope) =>
      Boolean(scope?.excludingPersonalProjects) || nodesOf(scope?.excludingProjects).length > 0,
    component: ProjectsToggleList,
    drawerProps: (scope, { isGroup, isInstanceLevel }) => ({
      isGroup,
      isInstanceLevel,
      including: false,
      projects: nodesOf(scope.excludingProjects),
      excludingPersonalProjects: Boolean(scope.excludingPersonalProjects),
    }),
    listProps: (scope, { isGroup, isInstanceLevel }) => ({
      isGroup,
      isInstanceLevel,
      inlineList: true,
      bulletStyle: false,
      projectsToShow: 2,
      including: false,
      projects: nodesOf(scope.excludingProjects),
      excludingPersonalProjects: Boolean(scope.excludingPersonalProjects),
    }),
  },
];

export const resolveScopeType = (policyScope, variant, context) => {
  const entry = SCOPE_TYPE_CONFIG.find(({ predicate }) => predicate(policyScope));
  if (!entry) {
    return {
      component: ScopeDefaultLabel,
      props: {
        policyScope,
        isGroup: context.isGroup,
        linkedItems: context.linkedSppItems,
      },
    };
  }
  const propsKey = VARIANT_TO_PROPS_KEY[variant];
  if (!propsKey) {
    throw new Error(`Unknown scope variant: "${variant}". Expected "drawer" or "list".`);
  }
  return {
    component: entry.component,
    props: entry[propsKey](policyScope, context),
  };
};
