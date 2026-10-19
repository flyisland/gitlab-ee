import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SchemaDomainMap from 'ee/orbit/dashboard/schema/schema_domain_map.vue';
import { schemaDomains } from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

describe('SchemaDomainMap', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMountExtended(SchemaDomainMap, {
      propsData: { domains: schemaDomains(mockExpandedSchema) },
    });
  };

  const findDomains = () => wrapper.findAllByTestId('schema-domain');

  beforeEach(() => {
    createComponent();
  });

  it('puts Projects in the center with its entity names, and other domains around it with a count', () => {
    expect(findDomains().wrappers.map((domain) => domain.text())).toEqual([
      expect.stringMatching(/Projects\s+User, Project/),
      expect.stringMatching(/Pipelines\s+3 entities/),
    ]);
  });

  it('draws one line from the center to each domain around it', () => {
    expect(wrapper.findAll('line')).toHaveLength(1);
  });

  it('emits select with the entity the domain opens on', async () => {
    await findDomains()
      .wrappers.find((domain) => domain.text().startsWith('Pipelines'))
      .trigger('click');

    expect(wrapper.emitted('select')).toEqual([['Pipeline']]);
  });
});
