import { has, pickBy, groupBy, omit } from 'lodash-es';

export const groupJobs = (stages, jobs) => {
  const groupedJobs = {};

  stages?.forEach((stage) => {
    groupedJobs[stage] = [];
  });

  Object.entries(jobs).forEach(([jobName, job]) => {
    // if no stage, then it is a test job.
    const stageName = job.stage || 'test';

    const composedJob = {
      ...job,
      name: jobName,
    };

    if (!groupedJobs[stageName]) {
      groupedJobs[stageName] = [];
    }

    groupedJobs[stageName].push(composedJob);
  });

  return omit(
    {
      ...groupBy(jobs, 'stage'),
      ...groupedJobs,
    },
    'undefined',
  );
};

export const filterJobs = (parsedDocument) => {
  return pickBy(parsedDocument, (document) => {
    return !Array.isArray(document) && has(document, 'stage');
  });
};
