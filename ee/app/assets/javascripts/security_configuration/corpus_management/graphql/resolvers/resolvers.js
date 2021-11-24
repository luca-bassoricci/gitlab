import produce from 'immer';
import { corpuses } from 'ee_jest/security_configuration/corpus_management/mock_data';
import { publishPackage } from '~/api/packages_api';
import axios from '~/lib/utils/axios_utils';
import getCorpusesQuery from '../queries/get_corpuses.query.graphql';
import updateProgress from '../mutations/update_progress.mutation.graphql';

export default {
  Query: {
    /* eslint-disable no-unused-vars */
    mockedPackages(_, { projectPath }) {
      return {
        // Mocked data goes here
        totalSize: 20.45e8,
        data: corpuses,
        __typename: 'MockedPackages',
      };
    },
    /* eslint-disable no-unused-vars */
    uploadState(_, { projectPath }) {
      return {
        isUploading: false,
        progress: 0,
        cancelSource: null,
        __typename: 'UploadState',
      };
    },
  },
  Mutation: {
    addCorpus: (_, { name, projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        draftState.uploadState.isUploading = false;
        draftState.uploadState.progress = 0;

        draftState.mockedPackages.data = [
          ...draftState.mockedPackages.data,
          {
            name,
            lastUpdated: new Date().toString(),
            lastUsed: new Date().toString(),
            latestJobPath: '',
            target: '',
            downloadPath: 'farias-gl/go-fuzzing-example/-/jobs/959593462/artifacts/download',
            size: 4e8,
            __typename: 'CorpusData',
          },
        ];
        draftState.mockedPackages.totalSize += 4e8;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
    deleteCorpus: (_, { name, projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const mockedCorpuses = draftState.mockedPackages;
        // Filter out deleted corpus
        mockedCorpuses.data = mockedCorpuses.data.filter((corpus) => {
          return corpus.name !== name;
        });
        // Re-compute total file size
        mockedCorpuses.totalSize = mockedCorpuses.data.reduce((totalSize, corpus) => {
          return totalSize + corpus.size;
        }, 0);
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
    uploadCorpus: (_, { projectPath, name, files }, { cache, client }) => {
      const onUploadProgress = (e) => {
        client.mutate({
          mutation: updateProgress,
          variables: { projectPath, progress: Math.round((e.loaded / e.total) * 100) },
        });
      };

      const { CancelToken } = axios;
      const source = CancelToken.source();

      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = true;
        uploadState.cancelSource = source;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });

      publishPackage(
        { projectPath, name, version: 0, fileName: name, files },
        { status: 'hidden', select: 'package_file' },
        { onUploadProgress, cancelToken: source.token },
      );
    },
    updateProgress: (_, { projectPath, progress }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = true;
        uploadState.progress = progress;

        if (progress >= 100) {
          uploadState.isUploading = false;
          uploadState.cancelSource = null;
        }
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
    resetCorpus: (_, { projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      sourceData.uploadState.cancelSource?.cancel();

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = false;
        uploadState.progress = 0;
        uploadState.cancelToken = null;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
  },
};
