import Api from '~/api';

// Mock ENUMS

// RUNNER_TYPE

const RUNNER_TYPE_INSTANCE_TYPE = 'INSTANCE_TYPE';
const RUNNER_TYPE_GROUP_TYPE = 'GROUP_TYPE';
const RUNNER_TYPE_PROJECT_TYPE = 'PROJECT_TYPE';

// STATUS

const RUNNER_STATUS_ONLINE = 'ONLINE';
const RUNNER_STATUS_OFFLINE = 'OFFLINE';
const RUNNER_STATUS_NOT_CONNECTED = 'NOT_CONNECTED';
const RUNNER_STATUS_PAUSED = 'PAUSED';

export const resolvers = {
  Query: {
    async runners() {
      const { data } = await Api.getRunners();

      return data.map(async ({ id }) => {
        // CAUTION! Horrible N+1!
        const [runner, jobs] = await Promise.all([Api.getRunner(id), Api.getRunnerJobs(id)]);

        const jobsCount = jobs.headers['x-total'];

        const {
          description,
          ip_address,
          active,
          is_shared: isShared,
          name,
          status,
          projects,
          locked,
          contacted_at,
          tag_list,
          version,
          short_sha,
        } = runner.data;

        let runnerType;
        // Deduce runner type, not always accurate (!)
        if (isShared) {
          runnerType = RUNNER_TYPE_INSTANCE_TYPE;
        } else if (projects && projects.length) {
          runnerType = RUNNER_TYPE_PROJECT_TYPE;
        } else {
          runnerType = RUNNER_TYPE_GROUP_TYPE;
        }

        const statusMap = {
          paused: RUNNER_STATUS_PAUSED,
          not_connected: RUNNER_STATUS_NOT_CONNECTED,
          online: RUNNER_STATUS_ONLINE,
          offline: RUNNER_STATUS_OFFLINE,
        };

        return {
          id,
          description,
          ipAddress: ip_address,
          active,
          runnerType,
          name,
          status: statusMap[status],
          locked,
          lastContactAt: contacted_at,
          tagList: tag_list,
          version,
          shortSha: short_sha,
          jobsCount,
          projectsCount: projects.length,
          __typename: 'Runner', // eslint-disable-line @gitlab/require-i18n-strings
        };
      });
    },
  },
};
