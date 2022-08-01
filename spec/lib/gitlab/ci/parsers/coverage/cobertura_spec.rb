# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Coverage::Cobertura do
  let(:xml_data) { double }
  let(:coverage_report) { double }
  let(:project_path) { double }
  let(:paths) { %w[file1 file2] }
  let(:project) { instance_double('Project', full_path: project_path) }
  let(:pipeline) { instance_double('Ci::Pipeline', project: project, all_worktree_paths: paths) }

  subject(:parse_report) { described_class.new(xml_data, coverage_report, pipeline: pipeline).parse! }

  before do
    allow_next_instance_of(Nokogiri::XML::SAX::Parser) do |document|
      allow(document).to receive(:parse)
    end
  end

  it 'uses Sax parser' do
    expect(Gitlab::Ci::Parsers::Coverage::SaxDocument).to receive(:new)

    parse_report
  end

  it 'includes worktree_paths and project path' do
    expect(project).to receive(:full_path)
    expect(pipeline).to receive(:all_worktree_paths)

    parse_report
  end
end
