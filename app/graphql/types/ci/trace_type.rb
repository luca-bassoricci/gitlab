# frozen_string_literal: true

module Types
  module Ci
    class TraceType < BaseObject
      include PerQueryLimits

      graphql_name 'BuildTrace'

      authorize :read_build_trace

      MAX_TAIL_LENGTH_FOR_JOBS = 25

      def self.trace_field(name, description)
        field(name, GraphQL::STRING_TYPE, null: true, description: description) do
          extras [:parent]
          argument :full, ::GraphQL::BOOLEAN_TYPE,
            default_value: false,
            required: false,
            description: 'Retrieve the full trace. Not allowed when selecting jobs from Pipeline.jobs. (default value: false).'

          argument :tail, ::GraphQL::INT_TYPE,
            default_value: 10,
            required: false,
            description: "Take only the last N lines. (default value: 10, max #{MAX_TAIL_LENGTH_FOR_JOBS} when called from Pipeline.jobs.trace)."
        end
      end

      trace_field :raw, 'The trace as plaintext.'
      trace_field :html, 'The trace as HTML.'

      field :sections, [::Types::Ci::TraceSectionType], null: true,
        description: 'The sections in the trace.',
        extras: [:lookahead]

      def raw(**args)
        n = tail_argument(**args)
        trace.raw(last_lines: n)
      end

      def html(**args)
        n = tail_argument(**args)
        trace.html(last_lines: n)
      end

      def sections(lookahead:)
        trace.job.parse_trace_sections!

        sections = trace.job.trace_sections
          .order(byte_start: :asc) # rubocop: disable CodeReuse/ActiveRecord

        if lookahead.selects?(:name)
          sections = sections.preload(:section_name) # rubocop: disable CodeReuse/ActiveRecord
        end

        if lookahead.selects?(:content)
          sections = sections.preload(:build) # rubocop: disable CodeReuse/ActiveRecord
        end

        sections
      end

      private

      def tail_argument(parent:, tail: 10, full: false)
        if called_from_pipeline_jobs?(parent)
          forbid_full_trace_in_jobs! if full
          tail = [MAX_TAIL_LENGTH_FOR_JOBS, tail].min
        end

        full ? nil : tail
      end

      def called_from_pipeline_jobs?(parent)
        return false unless parent

        case parent.path
        in [*_, 'nodes', Integer, _]
          true
        in [*_, 'edges', Integer, 'node', _]
          true
        else
          false
        end
      end

      def forbid_full_trace_in_jobs!
        raise ::Gitlab::Graphql::Errors::ArgumentError, 'Cannot request full trace from Pipeline.jobs'
      end

      alias_method :trace, :object
    end
  end
end
