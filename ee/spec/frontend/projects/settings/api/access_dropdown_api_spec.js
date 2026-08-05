import { getMemberRoles } from 'ee/projects/settings/api/access_dropdown_api';

describe('getMemberRoles', () => {
  it('resolves with mocked member roles data', async () => {
    const result = await getMemberRoles(123);

    expect(result).toEqual({
      data: [
        {
          id: 1,
          name: 'Lead Developer',
          base_access_level: 30,
          description: 'Senior developers with merge rights',
        },
      ],
    });
  });
});
