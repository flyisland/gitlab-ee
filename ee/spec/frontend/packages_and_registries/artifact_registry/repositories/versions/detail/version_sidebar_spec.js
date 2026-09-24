import { RouterLinkStub } from '@vue/test-utils';
import { GlBadge, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import VersionSidebar from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/version_sidebar.vue';
import {
  MOCK_COMMIT_SHA,
  mockCiPublisher,
  mockPublishingProject,
  mockRepository,
  mockVersionDetails,
} from '../../../mock_data';

describe('ArtifactRegistryVersionSidebar', () => {
  let wrapper;

  const createComponent = ({ repository = {}, version = {} } = {}) => {
    wrapper = shallowMountExtended(VersionSidebar, {
      propsData: {
        repository: { name: mockRepository.name, kind: 'HOSTED', ...repository },
        version: mockVersionDetails(version),
      },
      stubs: {
        GlSprintf,
        RouterLink: RouterLinkStub,
      },
    });
  };

  const findRepositoryLink = () => wrapper.findComponent(RouterLinkStub);
  const findKindBadge = () => wrapper.findComponent(GlBadge);
  const findRepositorySection = () => wrapper.findByTestId('version-repository');
  const findSize = () => wrapper.findByTestId('version-size');
  const findPublished = () => wrapper.findByTestId('version-published');
  const findUnknownPublished = () => wrapper.findByTestId('version-published-unknown');
  const findSourceSection = () => wrapper.findByTestId('version-source');
  const findCommit = () => wrapper.findByTestId('version-commit');
  const findManualPublish = () => wrapper.findByTestId('version-manual');
  const findAttribution = () => wrapper.findByTestId('version-attribution');
  const findUnknownSource = () => wrapper.findByTestId('version-source-unknown');

  describe('the repository section', () => {
    it('names the section with an h2, so the heading order does not skip a level', () => {
      createComponent();

      expect(findRepositorySection().find('h2').text()).toBe('Repository');
    });

    it('links the repository name to the repository it names', () => {
      createComponent();

      expect(findRepositoryLink().text()).toBe(mockRepository.name);
      expect(findRepositoryLink().props('to')).toEqual({
        name: 'repository_detail',
        params: { id: mockRepository.name },
      });
    });

    it('names the repository kind', () => {
      createComponent({ repository: { kind: 'REMOTE' } });

      expect(findKindBadge().text()).toBe('Remote');
    });
  });

  describe('the size row', () => {
    it('labels the version size', () => {
      createComponent();

      expect(findSize().text()).toMatchInterpolatedText('15.64 MiB Size');
    });

    it('renders a zero as a zero on a hosted repository', () => {
      createComponent({ version: { sizeBytes: '0' } });

      expect(findSize().text()).toMatchInterpolatedText('0 B Size');
    });

    it('hides when the version reports no size', () => {
      createComponent({ version: { sizeBytes: null } });

      expect(findSize().exists()).toBe(false);
    });

    it('hides rather than rendering NaN when the size is not a number', () => {
      createComponent({ version: { sizeBytes: 'not-a-number' } });

      expect(findSize().exists()).toBe(false);
    });

    it('hides on a remote repository', () => {
      createComponent({ repository: { kind: 'REMOTE' } });

      expect(findSize().exists()).toBe(false);
    });
  });

  describe('the published section', () => {
    it('names the section with an h2, so the heading order does not skip a level', () => {
      createComponent();

      expect(findPublished().find('h2').text()).toBe('Published');
    });

    it('renders the date the version was published', () => {
      createComponent();

      expect(findPublished().text()).toMatchInterpolatedText('Published Jun 10, 2026');
    });

    it('renders unknown, not an epoch date, when the version carries no timestamp', () => {
      createComponent({ version: { createdAt: null } });

      expect(findUnknownPublished().text()).toBe('Unknown');
    });
  });

  describe('the source section', () => {
    it('names the section with an h2, so the heading order does not skip a level', () => {
      createComponent();

      expect(findSourceSection().find('h2').text()).toBe('Source');
    });

    it('links the short commit sha to its commit', () => {
      createComponent();

      expect(findCommit().text()).toBe(MOCK_COMMIT_SHA.slice(0, 8));
      expect(findCommit().attributes('href')).toBe(
        `/${mockPublishingProject.fullPath}/-/commit/${MOCK_COMMIT_SHA}`,
      );
    });

    it('names the project and the publisher', () => {
      createComponent();

      expect(findAttribution().text()).toBe(
        `Published to ${mockPublishingProject.name} by ${mockCiPublisher.name}`,
      );
      expect(findAttribution().findComponent(GlLink).attributes('href')).toBe(
        mockPublishingProject.webPath,
      );
    });

    it('leaves the sha unlinked when the project does not resolve', () => {
      createComponent({ version: { project: null } });

      expect(findCommit().text()).toBe(MOCK_COMMIT_SHA.slice(0, 8));
      expect(findCommit().attributes('href')).toBeUndefined();
      expect(findAttribution().text()).toBe(`Published by ${mockCiPublisher.name}`);
    });

    it('names the project alone when there is no publisher', () => {
      createComponent({ version: { createdBy: null } });

      expect(findAttribution().text()).toBe(`Published to ${mockPublishingProject.name}`);
    });

    it('renders the commit alone when neither the project nor the publisher resolves', () => {
      createComponent({ version: { project: null, createdBy: null } });

      expect(findCommit().text()).toBe(MOCK_COMMIT_SHA.slice(0, 8));
      expect(findCommit().attributes('href')).toBeUndefined();
      expect(findAttribution().exists()).toBe(false);
      expect(findUnknownSource().exists()).toBe(false);
    });

    describe('a version published without a commit', () => {
      it('reads as a manual publish by its author, as the versions table reads it', () => {
        createComponent({ version: { gitCommitSha: null, project: null } });

        expect(findCommit().exists()).toBe(false);
        expect(findManualPublish().text()).toBe(`Manually published by ${mockCiPublisher.name}`);
        expect(findAttribution().exists()).toBe(false);
      });

      it('names the project beneath the manual publish, without repeating the author', () => {
        createComponent({ version: { gitCommitSha: null } });

        expect(findManualPublish().text()).toBe(`Manually published by ${mockCiPublisher.name}`);
        expect(findAttribution().text()).toBe(`Published to ${mockPublishingProject.name}`);
      });

      it('names the project alone when there is no publisher either', () => {
        createComponent({ version: { gitCommitSha: null, createdBy: null } });

        expect(findManualPublish().text()).toBe('Manually published');
        expect(findAttribution().text()).toBe(`Published to ${mockPublishingProject.name}`);
      });
    });

    it('renders unknown, not a manual publish, for a version carrying no attribution', () => {
      createComponent({
        version: { gitCommitSha: null, project: null, createdBy: null },
      });

      expect(findUnknownSource().text()).toBe('Unknown');
      expect(findCommit().exists()).toBe(false);
      expect(findManualPublish().exists()).toBe(false);
      expect(findAttribution().exists()).toBe(false);
    });
  });
});
