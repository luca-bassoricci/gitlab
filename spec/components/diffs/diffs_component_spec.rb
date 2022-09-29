# frozen_string_literal: true

require "spec_helper"

RSpec.describe Diffs::DiffsComponent, type: :component do
  include RepoHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:repository) { project.repository }
  let_it_be(:commit) { project.commit(sample_commit.id) }
  let_it_be(:diffs) { commit.diffs }
  let_it_be(:user) { create(:user) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project) }

  let(:component) do
    described_class.new(
      context: context,
      diffs: diffs,
      discussions: [],
      page_context: page_context,
      environment: environment,
      show_whitespace_toggle: show_whitespace_toggle,
      diff_notes_disabled: diff_notes_disabled,
      paginate_diffs: paginate_diffs,
      paginate_diffs_per_page: paginate_diffs_per_page,
      page: page
    )
  end

  let(:context) { commit }
  let(:page_context) { "is-commit" }
  let(:show_whitespace_toggle) { true }
  let(:diff_notes_disabled) { false }
  let(:paginate_diffs) { false }
  let(:paginate_diffs_per_page) { Projects::CommitController::COMMIT_DIFFS_PER_PAGE }
  let(:page) { 1 }
  let(:request_controller) { Projects::CommitController }

  let(:environment) do
    ::Environments::EnvironmentsByDeploymentsFinder.new(project, user, commit: commit, find_latest: true).execute.last
  end

  subject { rendered_content }

  before do
    with_request_url "#{project.full_path}/-/commit/#{commit.id}" do
      with_controller_class request_controller do
        render_inline component
      end
    end
  end

  shared_examples "rendered component" do
    it { is_expected.to have_selector(".diff-files-changed") }
    it { is_expected.to include(component.inline_diff_btn) }
    it { is_expected.to include(component.parallel_diff_btn) }
    it { is_expected.to include(component.whitespace_toggle) }
  end

  context "when a commit" do
    let(:page_context) { "is-commit" }

    it_behaves_like "rendered component"
  end

  context "when a merge request" do
    let(:page_context) { "is-merge-request" }

    it_behaves_like "rendered component"
  end

  describe "#page_context" do
    subject { component.page_context }

    context "when set by initializer" do
      it { is_expected.to eq(page_context) }
    end

    context "when commit" do
      let(:page_context) { nil }
      let(:context) { commit }

      it { is_expected.to eq("is-commit") }
    end

    context "when merge request" do
      let(:page_context) { nil }
      let(:context) { merge_request }
      let(:request_controller) { Projects::MergeRequests::DiffsController }

      it { is_expected.to eq("is-merge-request") }
    end
  end

  describe "#whitespace_toggle" do
    subject { component.whitespace_toggle }

    context "when whitespace toggle is disabled" do
      let(:show_whitespace_toggle) { false }

      it { is_expected.to be_nil }
    end
  end
end
