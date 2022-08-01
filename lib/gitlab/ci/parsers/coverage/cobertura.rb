# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Coverage
        class Cobertura
          InvalidXMLError = Class.new(Gitlab::Ci::Parsers::ParserError)
          InvalidLineInformationError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def initialize(blob, report, **context)
            @blob = blob
            @report = report
            @pipeline = context.delete(:pipeline)
          end

          def parse!
            project_path = @pipeline.project.full_path
            worktree_paths = @pipeline.all_worktree_paths

            Nokogiri::XML::SAX::Parser.new(SaxDocument.new(@report, project_path, worktree_paths)).parse(@blob)
          end
        end
      end
    end
  end
end
