const runnerFixture = (filename) => getJSONFixture(`graphql/runner/${filename}`);

// Fixtures generated by: spec/frontend/fixtures/runner.rb

// Admin queries
export const runnersData = runnerFixture('get_runners.query.graphql.json');
export const runnersDataPaginated = runnerFixture('get_runners.query.graphql.paginated.json');
export const runnerData = runnerFixture('get_runner.query.graphql.json');

// Group queries
export const groupRunnersData = runnerFixture('get_group_runners.query.graphql.json');
export const groupRunnersDataPaginated = runnerFixture(
  'get_group_runners.query.graphql.paginated.json',
);
