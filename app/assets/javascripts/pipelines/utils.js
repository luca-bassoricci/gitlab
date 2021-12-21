import * as Sentry from '@sentry/browser';
import { pickBy } from 'lodash';
import { SUPPORTED_FILTER_PARAMETERS, NEEDS_PROPERTY } from './constants';

/*
    The following functions are the main engine in transforming the data as
    received from the endpoint into the format the d3 graph expects.

    Input is of the form:
    [nodes]
      nodes: [{category, name, jobs, size}]
        category is the stage name
        name is a group name; in the case that the group has one job, it is
          also the job name
        size is the number of parallel jobs
        jobs: [{ name, needs}]
          job name is either the same as the group name or group x/y
          needs: [job-names]
          needs is an array of job-name strings

    Output is of the form:
    { nodes: [node], links: [link] }
      node: { name, category }, + unused info passed through
      link: { source, target, value }, with source & target being node names
        and value being a constant

    We create nodes in the GraphQL update function, and then here we create the node dictionary,
    then create links, and then dedupe the links, so that in the case where
    job 4 depends on job 1 and job 2, and job 2 depends on job 1, we show only a single link
    from job 1 to job 2 then another from job 2 to job 4.

    CREATE LINKS
    nodes.name -> target
    nodes.name.needs.each -> source (source is the name of the group, not the parallel job)
    10 -> value (constant)
  */

export const createNodeDict = (nodes, { needsKey = NEEDS_PROPERTY } = {}) => {
  return nodes.reduce((acc, node) => {
    const newNode = {
      ...node,
      needs: node.jobs.map((job) => job[needsKey] || []).flat(),
    };

    if (node.size > 1) {
      node.jobs.forEach((job) => {
        acc[job.name] = newNode;
      });
    }

    acc[node.name] = newNode;
    return acc;
  }, {});
};

export const validateParams = (params) => {
  return pickBy(params, (val, key) => SUPPORTED_FILTER_PARAMETERS.includes(key) && val);
};

/**
 * This function takes the stages array and transform it
 * into a hash where each key is a job name and the job data
 * is associated to that key.
 * @param {Array} stages
 * @returns {Object} - Hash of jobs
 */
export const createJobsHash = (stages = []) => {
  const nodes = stages.flatMap(({ groups }) => groups);
  return createNodeDict(nodes);
};

/**
 * This function takes the jobs hash generated by
 * `createJobsHash` function and returns an easier
 * structure to work with for needs relationship
 * where the key is the job name and the value is an
 * array of all the needs this job has recursively
 * (includes the needs of the needs)
 * @param {Object} jobs
 * @returns {Object} - Hash of jobs and array of needs
 */
export const generateJobNeedsDict = (jobs = {}) => {
  const arrOfJobNames = Object.keys(jobs);

  return arrOfJobNames.reduce((acc, value) => {
    const recursiveNeeds = (jobName) => {
      if (!jobs[jobName]?.needs) {
        return [];
      }

      return jobs[jobName].needs
        .reduce((needsAcc, job) => {
          // It's possible that a needs refer to an optional job
          // that is not defined in which case we don't add that entry
          if (!jobs[job]) {
            return needsAcc;
          }

          // If we already have the needs of a job in the accumulator,
          // then we use the memoized data instead of the recursive call
          // to save some performance.
          const newNeeds = acc[job] ?? recursiveNeeds(job);

          // In case it's a parallel job (size > 1), the name of the group
          // and the job will be different. This mean we also need to add the group name
          // to the list of `needs` to ensure we can properly reference it.
          const group = jobs[job];
          if (group.size > 1) {
            return [...needsAcc, job, group.name, newNeeds];
          }

          return [...needsAcc, job, newNeeds];
        }, [])
        .flat(Infinity);
    };

    // To ensure we don't have duplicates job relationship when 2 jobs
    // needed by another both depends on the same jobs, we remove any
    // duplicates from the array.
    const uniqueValues = Array.from(new Set(recursiveNeeds(value)));

    return { ...acc, [value]: uniqueValues };
  }, {});
};

export const reportToSentry = (component, failureType) => {
  Sentry.withScope((scope) => {
    scope.setTag('component', component);
    Sentry.captureException(failureType);
  });
};

export const reportMessageToSentry = (component, message, context) => {
  Sentry.withScope((scope) => {
    // eslint-disable-next-line @gitlab/require-i18n-strings
    scope.setContext('Vue data', context);
    scope.setTag('component', component);
    Sentry.captureMessage(message);
  });
};
