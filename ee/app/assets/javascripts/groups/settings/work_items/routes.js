import { getSettingsConfig } from 'ee/work_items/constants';
import ChangeLifecycleSteps from './custom_status/change_lifecycle/change_lifecycle_steps.vue';
import WorkItemSettingsHome from './work_item_settings_home.vue';

export const getRoutes = (fullPath, isRootGroup) => {
  const subGroupWorkItemSettingsConfig = {
    ...getSettingsConfig('subgroup'),
    showWorkItemTypesSettings: false,
    showEnabledWorkItemTypesSettings: true,
    showCustomFieldsSettings: false,
    showCustomStatusSettings: false,
    workItemSettingsLayout: 'availability',
  };
  return [
    {
      path: '/',
      name: 'workItemSettingsHome',
      component: WorkItemSettingsHome,
      props: {
        fullPath,
        config: isRootGroup ? getSettingsConfig('root') : subGroupWorkItemSettingsConfig,
      },
    },
    {
      path: `/lifecycle/:workItemType`,
      name: 'changeLifecycle',
      component: ChangeLifecycleSteps,
      props: { fullPath },
    },
  ];
};
