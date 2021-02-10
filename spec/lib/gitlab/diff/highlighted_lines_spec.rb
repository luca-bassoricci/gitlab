# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Diff::HighlightedLines do
  include RepoHelpers

  let_it_be(:project) { create(:project, :repository) }

  let(:commit) { project.commit(sample_commit.id) }
  let(:diff) { commit.raw_diffs.first }
  let(:diff_file) { Gitlab::Diff::File.new(diff, diff_refs: commit.diff_refs, repository: project.repository) }

  subject { described_class.new(diff_file) }

  context 'extracts new and old versions of the file' do
    it 'splits the diff into blob chunks' do
      expect(subject.new_chunks.size).to eq(3)
      expect(subject.new_chunks[1][0]).to eq("<span id=\"LC1\" class=\"line\" lang=\"ruby\"></span>\n")
      expect(subject.old_chunks.size).to eq(3)
      expect(subject.old_chunks[1][0]).to eq(%{<span id="LC1" class="line" lang="ruby">      <span class="k">raise</span> <span class="s2">"System commands must be given as an array of strings"</span></span>\n})
    end

    it 'maps lines to the lines in blob chunks' do
      expect(subject.mapper).to eq({
        1 => [:new, 1, 0],
        2 => [:new, 1, 1],
        3 => [:new, 1, 2],
        4 => [:old, 1, 0],
        5 => [:new, 1, 3],
        6 => [:new, 1, 4],
        7 => [:new, 1, 5],
        8 => [:new, 1, 6],
        9 => [:old, 1, 1],
        10 => [:old, 1, 2],
        11 => [:new, 1, 7],
        12 => [:new, 1, 8],
        13 => [:new, 1, 9],
        14 => [:new, 1, 10],
        15 => [:new, 1, 11],
        16 => [:new, 1, 12],
        17 => [:new, 1, 13],
        18 => [:new, 1, 14],
        19 => [:new, 1, 15],
        20 => [:new, 1, 16],
        21 => [:new, 1, 17],
        23 => [:new, 2, 0],
        24 => [:new, 2, 1],
        25 => [:new, 2, 2],
        26 => [:new, 2, 3],
        27 => [:new, 2, 4],
        28 => [:new, 2, 5],
        29 => [:new, 2, 6]
      })
    end
  end

  describe '#for' do
    it 'returns highlighted line for a line' do
      expect(subject.for(diff_file.diff_lines[23], 23)).to eq(" <span id=\"LC1\" class=\"line\" lang=\"ruby\"></span>\n")
      expect(subject.for(diff_file.diff_lines[5], 5)).to eq(%{+<span id="LC4" class="line" lang="ruby">      <span class="k">raise</span> <span class="no">RuntimeError</span><span class="p">,</span> <span class="s2">"System commands must be given as an array of strings"</span></span>\n})
    end
  end
end
