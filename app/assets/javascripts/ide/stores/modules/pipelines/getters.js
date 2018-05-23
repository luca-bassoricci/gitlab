export const hasLatestPipeline = state => !state.isLoadingPipeline && !!state.latestPipeline;

export const failedJobsCount = state =>
  state.stages.reduce(
    (acc, stage) => acc + stage.jobs.filter(j => j.status.label === 'failed').length,
    0,
  );

export const jobsCount = state => state.stages.reduce((acc, stage) => acc + stage.jobs.length, 0);
