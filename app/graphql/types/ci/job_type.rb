# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    # The permission is presented through `StageType` that has its own authorization
    class JobType < BaseObject
      graphql_name 'CiJob'

      connection_type_class(Types::LimitedCountableConnectionType)

      expose_permissions Types::PermissionTypes::Ci::Job

      field :allow_failure, ::GraphQL::Types::Boolean, null: false,
                                                       description: 'Whether the job is allowed to fail.'
      field :duration, GraphQL::Types::Int, null: true,
                                            description: 'Duration of the job in seconds.'
      field :id, ::Types::GlobalIDType[::CommitStatus].as('JobID'), null: true,
                                                                    description: 'ID of the job.'
      field :kind, type: ::Types::Ci::JobKindEnum, null: false,
                   description: 'Indicates the type of job.'
      field :name, GraphQL::Types::String, null: true,
                                           description: 'Name of the job.'
      field :needs, BuildNeedType.connection_type, null: true,
                                                   description: 'References to builds that must complete before the jobs run.'
      field :pipeline, Types::Ci::PipelineType, null: true,
                                                description: 'Pipeline the job belongs to.'
      field :stage, Types::Ci::StageType, null: true,
                                          description: 'Stage of the job.'
      field :status,
            type: ::Types::Ci::JobStatusEnum,
            null: true,
            description: "Status of the job."
      field :tags, [GraphQL::Types::String], null: true,
                                             description: 'Tags for the current job.'

      # Life-cycle timestamps:
      field :created_at, Types::TimeType, null: false,
                                          description: "When the job was created."
      field :finished_at, Types::TimeType, null: true,
                                           description: 'When a job has finished running.'
      field :queued_at, Types::TimeType, null: true,
                                         description: 'When the job was enqueued and marked as pending.'
      field :scheduled_at, Types::TimeType, null: true,
                                            description: 'Schedule for the build.'
      field :started_at, Types::TimeType, null: true,
                                          description: 'When the job was started.'

      # Life-cycle durations:
      field :queued_duration,
            type: Types::DurationType,
            null: true,
            description: 'How long the job was enqueued before starting.'

      field :active, GraphQL::Types::Boolean, null: false, method: :active?,
                                              description: 'Indicates the job is active.'
      field :artifacts, Types::Ci::JobArtifactType.connection_type, null: true,
                                                                    description: 'Artifacts generated by the job.'
      field :cancelable, GraphQL::Types::Boolean, null: false, method: :cancelable?,
                                                  description: 'Indicates the job can be canceled.'
      field :commit_path, GraphQL::Types::String, null: true,
                                                  description: 'Path to the commit that triggered the job.'
      field :coverage, GraphQL::Types::Float, null: true,
                                              description: 'Coverage level of the job.'
      field :created_by_tag, GraphQL::Types::Boolean, null: false,
                                                      description: 'Whether the job was created by a tag.', method: :tag?
      field :detailed_status, Types::Ci::DetailedStatusType, null: true,
                                                             description: 'Detailed status of the job.'
      field :downstream_pipeline, Types::Ci::PipelineType, null: true,
                                                           description: 'Downstream pipeline for a bridge.'
      field :manual_job, GraphQL::Types::Boolean, null: true,
                                                  description: 'Whether the job has a manual action.'
      field :manual_variables, ManualVariableType.connection_type, null: true,
                                                                   description: 'Variables added to a manual job when the job is triggered.'
      field :playable, GraphQL::Types::Boolean, null: false, method: :playable?,
                                                description: 'Indicates the job can be played.'
      field :previous_stage_jobs_or_needs, Types::Ci::JobNeedUnion.connection_type, null: true,
                                                                                    description: 'Jobs that must complete before the job runs. Returns `BuildNeed`, which is the needed jobs if the job uses the `needs` keyword, or the previous stage jobs otherwise.'
      field :ref_name, GraphQL::Types::String, null: true,
                                               description: 'Ref name of the job.'
      field :ref_path, GraphQL::Types::String, null: true,
                                               description: 'Path to the ref.'
      field :retried, GraphQL::Types::Boolean, null: true,
                                               description: 'Indicates that the job has been retried.'
      field :retryable, GraphQL::Types::Boolean, null: false, method: :retryable?,
                                                 description: 'Indicates the job can be retried.'
      field :scheduling_type, GraphQL::Types::String, null: true,
                                                      description: 'Type of job scheduling. Value is `dag` if the job uses the `needs` keyword, and `stage` otherwise.'
      field :short_sha, type: GraphQL::Types::String, null: false,
                        description: 'Short SHA1 ID of the commit.'
      field :stuck, GraphQL::Types::Boolean, null: false, method: :stuck?,
                                             description: 'Indicates the job is stuck.'
      field :triggered, GraphQL::Types::Boolean, null: true,
                                                 description: 'Whether the job was triggered.'

      def kind
        return ::Ci::Build unless [::Ci::Build, ::Ci::Bridge].include?(object.class)

        object.class
      end

      def pipeline
        Gitlab::Graphql::Loaders::BatchModelLoader.new(::Ci::Pipeline, object.pipeline_id).find
      end

      def downstream_pipeline
        object.downstream_pipeline if object.respond_to?(:downstream_pipeline)
      end

      def tags
        object.tags.map(&:name) if object.is_a?(::Ci::Build)
      end

      def detailed_status
        object.detailed_status(context[:current_user])
      end

      def artifacts
        if object.is_a?(::Ci::Build)
          object.job_artifacts
        end
      end

      def previous_stage_jobs_or_needs
        if object.scheduling_type == 'stage'
          Gitlab::Graphql::Lazy.with_value(previous_stage_jobs) do |jobs|
            jobs
          end
        else
          object.needs
        end
      end

      def previous_stage_jobs
        BatchLoader::GraphQL.for([object.pipeline, object.stage_idx - 1]).batch(default_value: []) do |tuples, loader|
          tuples.group_by(&:first).each do |pipeline, keys|
            positions = keys.map(&:second)

            stages = pipeline.stages.by_position(positions)

            stages.each do |stage|
              loader.call([pipeline, stage.position], stage.latest_statuses)
            end
          end
        end
      end

      def stage
        ::Gitlab::Graphql::Lazy.with_value(pipeline) do |pl|
          BatchLoader::GraphQL.for([pl, object.stage]).batch do |ids, loader|
            by_pipeline = ids
              .group_by(&:first)
              .transform_values { |grp| grp.map(&:second) }

            by_pipeline.each do |p, names|
              p.stages.by_name(names).each { |s| loader.call([p, s.name], s) }
            end
          end
        end
      end

      # This class is a secret union!
      # TODO: turn this into an actual union, so that fields can be referenced safely!
      def id
        return unless object.id.present?

        model_name = object.type || ::CommitStatus.name
        id = object.id
        Gitlab::GlobalId.build(model_name: model_name, id: id)
      end

      def commit_path
        ::Gitlab::Routing.url_helpers.project_commit_path(object.project, object.sha)
      end

      def ref_name
        object&.ref
      end

      def ref_path
        ::Gitlab::Routing.url_helpers.project_commits_path(object.project, ref_name)
      end

      def coverage
        object&.coverage
      end

      def manual_job
        object.try(:action?)
      end

      def triggered
        object.try(:trigger_request)
      end

      def manual_variables
        if object.manual? && object.respond_to?(:job_variables)
          object.job_variables
        else
          []
        end
      end
    end
  end
end
