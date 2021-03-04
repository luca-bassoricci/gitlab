# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Diff::HighlightedLines do
  include RepoHelpers

  let_it_be(:project) { create(:project, :repository) }

  let(:commit) { project.commit(sample_commit.id) }
  let(:diff) { commit.raw_diffs.first }
  let(:diff_file) { Gitlab::Diff::File.new(diff, diff_refs: commit.diff_refs, repository: project.repository) }

  subject { described_class.new(diff_file) }

  describe '#for' do
    it 'returns highlighted line for a line' do
      highlighted_line = diff_file.diff_lines[23]
      expect(subject.for(highlighted_line)).to eq("<span id=\"LC1\" class=\"line\" lang=\"\"></span>\n")
      expect(subject.for(highlighted_line)).to be_html_safe

      another_highlighted_line = diff_file.diff_lines[5]
      expect(subject.for(another_highlighted_line)).to eq(%{<span id="LC4" class="line" lang="">      raise RuntimeError, "System commands must be given as an array of strings"</span>\n})
      expect(subject.for(another_highlighted_line)).to be_html_safe
    end
  end
end
