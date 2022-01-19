# frozen_string_literal: true

class IdeController < ApplicationController
  layout 'fullscreen'

  include ClientsidePreviewCSP
  include StaticObjectExternalStorageCSP
  include Gitlab::Utils::StrongMemoize

  before_action :authorize_read_project!

  before_action do
    push_frontend_feature_flag(:build_service_proxy)
    push_frontend_feature_flag(:schema_linting)
    push_frontend_feature_flag(:reject_unsigned_commits_by_gitlab, default_enabled: :yaml)
    push_frontend_feature_flag(:gitlab_vscode, default_enabled: :yaml)
    define_index_vars
  end
  
  content_security_policy do |p|
    default_connect_src = p.directives['connect-src'] || p.directives['default-src']
    default_frame_src = p.directives['frame-src'] || p.directives['default-src']
    connect_src = Array.wrap(default_connect_src) | ['*.vo.msecnd.net', 'vortex.data.microsoft.com', 'default.exp-tas.com', 'vscodeweb.azureedge.net', 'vscodeexperiments.azureedge.net', '*.vscode-webview.net', 'marketplace.visualstudio.com', '*.vsassets.io', 'open-vsx.org', 'openvsxorg.blob.core.windows.net']
    frame_src = Array.wrap(default_frame_src) | ['*.vscode-webview.net']
    p.connect_src(*connect_src)
    p.frame_src(*frame_src)
  end

  feature_category :web_ide

  def index
    Gitlab::UsageDataCounters::WebIdeCounter.increment_views_count
  end

  private

  def authorize_read_project!
    render_404 unless can?(current_user, :read_project, project)
  end

  def define_index_vars
    return unless project

    @branch = params[:branch]
    @path = params[:path]
    @merge_request = params[:merge_request_id]
    @fork_info = fork_info(project, @branch)
  end

  def fork_info(project, branch)
    return if can?(current_user, :push_code, project)

    existing_fork = current_user.fork_of(project)

    if existing_fork
      path = helpers.ide_edit_path(existing_fork, branch, '')
      { ide_path: path }
    elsif can?(current_user, :fork_project, project)
      path = helpers.ide_fork_and_edit_path(project, branch, '', with_notice: false)
      { fork_path: path }
    end
  end

  def project
    strong_memoize(:project) do
      next unless params[:project_id].present?

      Project.find_by_full_path(params[:project_id])
    end
  end
end
