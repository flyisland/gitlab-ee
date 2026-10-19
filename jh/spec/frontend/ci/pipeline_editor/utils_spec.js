import { groupJobs, filterJobs } from 'jh/ci/pipeline_editor/utils';

const validStages = ['build', 'test', 'deploy'];
const emptyStages = [];

const buildJob = {
  name: 'build job',
  stage: 'build',
};

const deployJob = {
  name: 'deploy job',
  stage: 'deploy',
};

const testJob = {
  name: 'test job',
  stage: 'test',
};

const noStageJob = {
  name: 'no stage',
};

const stagedJobs = [testJob, buildJob, deployJob];

const unstagedJobs = [noStageJob, noStageJob];

describe('pipeline editor utils', () => {
  describe('#groupJobs', () => {
    it('should group non-test jobs by stage', () => {
      const groupedJobs = groupJobs(validStages, stagedJobs);
      const keys = Object.keys(groupedJobs);
      expect(keys).toHaveLength(3);

      keys.forEach((stage) => {
        expect(groupedJobs[stage]).toHaveLength(1);
      });
    });

    it('should group jobs without stage to test stage', () => {
      const groupedJobs = groupJobs(emptyStages, unstagedJobs);

      expect(Object.keys(groupedJobs)).toHaveLength(1);
      expect(groupedJobs.test).toHaveLength(2);
    });
  });

  describe('#filterJobs', () => {
    const parsedDocument = {
      stages: validStages,
      deployJob,
      testJob,
      buildJob,
    };

    it('filters jobs out of the document object', () => {
      const filteredDocument = filterJobs(parsedDocument);
      expect(Object.keys(filteredDocument)).toHaveLength(3);
      expect(filteredDocument).not.toHaveProperty('stages');
    });
  });
});
