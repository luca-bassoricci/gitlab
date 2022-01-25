import { start } from 'gitlab-vscode';
import { cleanTrailingSlash } from './stores/utils';

export const initGitlabVSCode = async (el) => {
  const project = JSON.parse(el.dataset.project);
  const nonce = el.dataset.cspNonce;
  el.style.position = 'relative';

  const baseUrl = new URL(process.env.GITLAB_VSCODE_PUBLIC_PATH, window.location.href);

  await start(el, {
    baseUrl: cleanTrailingSlash(baseUrl.href),
    projectPath: project.path_with_namespace,
    ref: el.dataset.branchName,
    gitlabUrl: gon.gitlab_url,
    nonce,
  });
};
