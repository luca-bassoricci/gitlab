# frozen_string_literal: true

module Diffs
  class DiffsComponent < BaseComponent
    def initialize(
      context:,
      diffs:,
      discussions:,
      page_context: nil,
      environment: nil,
      show_whitespace_toggle: true,
      diff_notes_disabled: false,
      paginate_diffs: false,
      paginate_diffs_per_page: nil,
      page: nil
    )
      @context = context
      @diffs = diffs
      @discussions = discussions
      @environment = environment
      @page_context = page_context
      @show_whitespace_toggle = show_whitespace_toggle
      @diff_notes_disabled = diff_notes_disabled
      @load_diff_files_async = Feature.enabled?(:async_commit_diff_files, @project) && self.page_context == "is-commit"
      @paginate_diffs = paginate_diffs && !@load_diff_files_async
      @paginate_diffs_per_page = paginate_diffs_per_page
      @page = page
    end

    def project
      @diffs.project
    end

    def diff_files
      helpers.conditionally_paginate_diff_files(
        @diffs,
        paginate: @paginate_diffs,
        per: @paginate_diffs_per_page,
        page: @page
      )
    end

    def render_diffs
      render partial: 'projects/diffs/file',
             collection: diff_files,
             as: :diff_file,
             locals: {
               project: project,
               environment: @environment,
               diff_page_context: page_context
             }
    end

    def page_context
      @page_context ||=
        case context.class
        when Commit
          "is-commit"
        when MergeRequest
          "is-merge-request"
        end
    end

    def can_create_note?
      !@diff_notes_disabled && can?(current_user, :create_note, project)
    end

    def whitespace_toggle
      return unless @show_whitespace_toggle

      if current_controller?(:commit)
        helpers.commit_diff_whitespace_link(project, @context, class: 'd-none d-sm-inline-block')
      elsif current_controller?('projects/merge_requests/diffs')
        helpers.diff_merge_request_whitespace_link(project, context, class: 'd-none d-sm-inline-block')
      elsif current_controller?(:compare)
        helpers.diff_compare_whitespace_link(project, params[:from], params[:to], class: 'd-none d-sm-inline-block')
      elsif current_controller?(:wikis)
        helpers.toggle_whitespace_link(url_for(params_with_whitespace), class: 'd-none d-sm-inline-block')
      end
    end

    def expand_diffs_toggle
      return if diffs_expanded?
      return unless diff_files.any?(&:collapsed?)

      link_to _('Expand all'), url_for(safe_params.merge(expanded: 1, format: nil)), class: 'gl-button btn btn-default'
    end

    def inline_diff_btn
      diff_btn('Inline', 'inline', helpers.diff_view == :inline)
    end

    def parallel_diff_btn
      diff_btn('Side-by-side', 'parallel', helpers.diff_view == :parallel)
    end

    private

    def diff_btn(title, name, selected)
      params_copy = safe_params.dup
      params_copy[:view] = name

      # Always use HTML to handle case where JSON diff rendered this button
      params_copy.delete(:format)

      args = {
        id: "#{name}-diff-btn",
        class: (selected ? "btn gl-button btn-default selected" : "btn gl-button btn-default"),
        data: { view_type: name }
      }

      link_to url_for(params_copy), args do
        title
      end
    end
  end
end
