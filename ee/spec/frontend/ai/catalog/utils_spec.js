import { getByVersionKey, resolveVersion } from 'ee/ai/catalog/utils';
import { VERSION_LATEST, VERSION_PINNED, VERSION_PINNED_GROUP } from 'ee/ai/catalog/constants';

describe('AI Catalog Utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  /**
    Versioning utilities
   */

  const EXP_LATEST = { id: '1', name: 'Latest' };
  const EXP_PINNED_PROJECT = { id: '2', name: 'Project pinned' };
  const EXP_PINNED_GROUP = { id: '3', name: 'Group pinned' };

  describe('getByVersionKey', () => {
    describe('handles dot notation correctly', () => {
      it.each`
        description                    | obj                                                                       | keys                                           | expected
        ${'single-level key'}          | ${{ latestVersion: EXP_LATEST }}                                          | ${'latestVersion'}                             | ${EXP_LATEST}
        ${'nested key (dot notation)'} | ${{ configurationForProject: { pinnedItemVersion: EXP_PINNED_PROJECT } }} | ${'configurationForProject.pinnedItemVersion'} | ${EXP_PINNED_PROJECT}
        ${'arbitrarily deep keys'}     | ${{ level1: { level2: { level3: { value: 'deep value' } } } }}            | ${'level1.level2.level3.value'}                | ${'deep value'}
      `('returns the value at $description', ({ obj, keys, expected }) => {
        expect(getByVersionKey(obj, keys)).toEqual(expected);
      });
    });

    describe('handles falsy key values correctly', () => {
      it.each`
        description                         | obj                                                                | keys
        ${'key does not exist'}             | ${{ latestVersion: { id: '1' } }}                                  | ${'nonexistent'}
        ${'nested key path does not exist'} | ${{ configurationForProject: { pinnedItemVersion: { id: '2' } } }} | ${'configurationForProject.nonexistent.value'}
        ${'intermediate key is null'}       | ${{ configurationForProject: null }}                               | ${'configurationForProject.pinnedItemVersion'}
        ${'key is empty string'}            | ${{ latestVersion: { id: '1' } }}                                  | ${''}
        ${'key is null'}                    | ${{ latestVersion: { id: '1' } }}                                  | ${null}
        ${'key is undefined'}               | ${{ latestVersion: { id: '1' } }}                                  | ${undefined}
      `('returns undefined when $description', ({ obj, keys }) => {
        const result = getByVersionKey(obj, keys);
        expect(result).toBeUndefined();
      });
    });

    describe('returns correct version based on configuration presence', () => {
      const obj = {
        latestVersion: EXP_LATEST,
        configurationForProject: {
          pinnedItemVersion: EXP_PINNED_PROJECT,
        },
        configurationForGroup: {
          pinnedItemVersion: EXP_PINNED_GROUP,
        },
      };

      it.each`
        versionKey              | expectedResult
        ${VERSION_PINNED}       | ${EXP_PINNED_PROJECT}
        ${VERSION_PINNED_GROUP} | ${EXP_PINNED_GROUP}
        ${VERSION_LATEST}       | ${EXP_LATEST}
      `(
        'returns the correct value for $versionKey constant key',
        ({ versionKey, expectedResult }) => {
          const result = getByVersionKey(obj, versionKey);

          expect(result).toEqual(expectedResult);
        },
      );
    });
  });

  describe('resolveVersion', () => {
    describe('handles when isGlobalNamespace is true correctly', () => {
      it('returns the latestVersion', () => {
        const mockItem = {
          latestVersion: EXP_LATEST,
          configurationForProject: { pinnedItemVersion: EXP_PINNED_PROJECT },
          configurationForGroup: { pinnedItemVersion: EXP_PINNED_GROUP },
        };
        const result = resolveVersion(mockItem, { isGlobalNamespace: true });
        expect(result).toEqual({ ...EXP_LATEST, key: VERSION_LATEST });
      });
    });

    describe('prioritizes returned configuration correctly when isGlobalNamespace is false', () => {
      const PINNED_PROJECT_CONFIG = { pinnedItemVersion: EXP_PINNED_PROJECT };
      const PINNED_GROUP_CONFIG = { pinnedItemVersion: EXP_PINNED_GROUP };
      // Note that here we assert against the actual runtime constants, since these are what are returned by the resolveVersion function
      it.each`
        description                                                             | latestVersion | pinnedProjectConfig      | pinnedGroupConfig      | expectedKey             | expectedConfig
        ${'prioritizes configurationForProject over configurationForGroup'}     | ${EXP_LATEST} | ${PINNED_PROJECT_CONFIG} | ${PINNED_GROUP_CONFIG} | ${VERSION_PINNED}       | ${EXP_PINNED_PROJECT}
        ${'returns VERSION_PINNED when configurationForGroup is undefined'}     | ${EXP_LATEST} | ${PINNED_PROJECT_CONFIG} | ${undefined}           | ${VERSION_PINNED}       | ${EXP_PINNED_PROJECT}
        ${'uses configurationForGroup when configurationForProject is missing'} | ${EXP_LATEST} | ${undefined}             | ${PINNED_GROUP_CONFIG} | ${VERSION_PINNED_GROUP} | ${EXP_PINNED_GROUP}
        ${'uses VERSION_LATEST when both configurations are missing'}           | ${EXP_LATEST} | ${undefined}             | ${undefined}           | ${VERSION_LATEST}       | ${EXP_LATEST}
      `(
        '$description',
        ({
          latestVersion,
          pinnedProjectConfig,
          pinnedGroupConfig,
          expectedKey,
          expectedConfig,
        }) => {
          const testItem = {
            latestVersion,
            configurationForProject: pinnedProjectConfig,
            configurationForGroup: pinnedGroupConfig,
          };
          const result = resolveVersion(testItem, { isGlobalNamespace: false });
          expect(result).toEqual({ ...expectedConfig, key: expectedKey });
        },
      );
    });
  });
});
