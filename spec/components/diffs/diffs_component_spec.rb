# frozen_string_literal: true

require "spec_helper"

RSpec.describe Diffs::DiffsComponent, type: :component do
  include RepoHelpers

  subject(:component) do
    described_class.new(
      context: commit,
      diffs: diffs,
      discussions: [],
      page_context: page_context,
      environment: [],
      show_whitespace_toggle: show_whitespace_toggle,
      diff_notes_disabled: diff_notes_disabled,
      paginate_diffs: paginate_diffs,
      paginate_diffs_per_page: paginate_diffs_per_page,
      page: page
    )
  end

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:repository) { project.repository }
  let_it_be(:commit) { project.commit(sample_commit.id) }
  let_it_be(:diffs) { commit.diffs }

  let(:show_whitespace_toggle) { true }
  let(:diff_notes_disabled) { false }
  let(:paginate_diffs) { false }
  let(:paginate_diffs_per_page) { Projects::CommitController::COMMIT_DIFFS_PER_PAGE }
  let(:page) { 1 }

  shared_examples "rendered component" do
    subject { rendered_content }

    let(:element) { page.find(".diff-files-changed") }

    before do
      # Warden doesn't work in the faked controller context
      allow(component).to receive(:can_create_note?).and_return(true)

      with_request_url "#{project.full_path}/-/commit/#{commit.id}" do
        render_inline component
      end
    end

    it { is_expected.to have_selector(".diff-files-changed") }
    it { is_expected.to include(component.inline_diff_btn) }
    it { is_expected.to include(component.parallel_diff_btn) }
  end

  context "when a commit" do
    let(:page_context) { "is-commit" }

    it_behaves_like "rendered component"
  end

  context "when a merge request" do
    let(:page_context) { "is-merge-request" }

    it_behaves_like "rendered component"
  end

  context "when whitespace toggle is disabled" do
    let(:show_whitespace_toggle) { false }
  end

  context "when diff notes are disabled" do
    let(:diff_notes_disabled) { true }
  end

  context "when paginate_diffs is set" do
    let(:paginate_diffs) { true }
  end

  describe "#page_context" do
  end

  describe "#whitespace_toggle" do
  end
end
