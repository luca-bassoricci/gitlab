import produce from 'immer';
import { publishPackage } from '~/api/packages_api';
import axios from '~/lib/utils/axios_utils';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPE_PACKAGES_PACKAGE } from '~/graphql_shared/constants';
import getCorpusesQuery from '../queries/get_corpuses.query.graphql';
import updateProgress from '../mutations/update_progress.mutation.graphql';
import uploadComplete from '../mutations/upload_complete.mutation.graphql';
import corpusCreate from '../mutations/corpus_create.mutation.graphql';

export default {
  Query: {
    /* eslint-disable no-unused-vars */
    uploadState(_, { projectPath }) {
      return {
        isUploading: false,
        progress: 0,
        cancelSource: null,
        uploadedPackageId: null,
        __typename: 'UploadState',
      };
    },
  },
  Mutation: {
    addCorpus: (_, { projectPath, packageId }, { cache, client }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        draftState.uploadState.isUploading = false;
        draftState.uploadState.progress = 0;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });

      client.mutate({
        mutation: corpusCreate,
        variables: {
          input: {
            fullPath: projectPath,
            packageId: convertToGraphQLId(TYPE_PACKAGES_PACKAGE, packageId),
          },
        },
      });
    },
    deleteCorpus: () => {
      // NO-OP
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

      const targetData = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = true;
        uploadState.cancelSource = source;
      });

      cache.writeQuery({ query: getCorpusesQuery, data: targetData, variables: { projectPath } });

      publishPackage(
        { projectPath, name, version: 0, fileName: name, files },
        { status: 'hidden', select: 'package_file' },
        { onUploadProgress, cancelToken: source.token },
      )
        .then(({ data }) => {
          client.mutate({
            mutation: uploadComplete,
            variables: { projectPath, packageId: data.package_id },
          });
        })
        .catch((e) => {
          /* TODO: Error handling */
        });
    },
    uploadComplete: (_, { projectPath, packageId }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = false;
        uploadState.cancelSource = null;
        uploadState.uploadedPackageId = packageId;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
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
