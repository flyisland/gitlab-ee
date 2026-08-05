export {
  buildUrl,
  getUsers,
  getGroups,
  getDeployKeys,
} from '~/projects/settings/api/access_dropdown_api';

// TODO: Replace mock with real API call once backend integration is ready.
// Real impl will be: axios.get(buildUrl(gon.relative_url_root || '', `/api/v4/groups/${namespaceId}/member_roles`))
// where buildUrl is imported from '~/projects/settings/api/access_dropdown_api'.
// eslint-disable-next-line no-unused-vars
export const getMemberRoles = (namespaceId) =>
  Promise.resolve({
    data: [
      {
        id: 1,
        name: 'Lead Developer', // eslint-disable-line @gitlab/require-i18n-strings
        base_access_level: 30,
        description: 'Senior developers with merge rights', // eslint-disable-line @gitlab/require-i18n-strings
      },
    ],
  });
