# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      # rubocop:disable Style/Documentation
      module PopulateSecurityScansLatestColumn
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        class CiBuild < ActiveRecord::Base
          include EachBatch

          self.table_name = 'ci_builds'

          has_many :artifacts, foreign_key: :job_id, class_name: 'CiJobArtifact'

          scope :retried, -> { where(retried: true) }
          scope :security_related, -> { joins(:artifacts).merge(CiJobArtifact.security) }
          scope :in_range, -> (start_id, end_id) { where(id: (start_id..end_id)) }
        end

        class CiJobArtifact < ActiveRecord::Base
          SECURITY_REPORT_FILE_TYPES = {
            sast: 5,
            dependency_scanning: 6,
            container_scanning: 7,
            dast: 8,
            secret_detection: 21,
            coverage_fuzzing: 23,
            api_fuzzing: 26,
            cluster_image_scanning: 27
          }.freeze

          self.table_name = 'ci_job_artifacts'

          enum file_type: SECURITY_REPORT_FILE_TYPES

          scope :security, -> { where(file_type: SECURITY_REPORT_FILE_TYPES.keys) }
        end

        class SecurityScan < ActiveRecord::Base
          self.table_name = 'security_scans'

          scope :by_build_ids, -> (build_ids) { where(build_id: build_ids) }
        end

        class_methods do
          def builds
            CiBuild.retried.security_related
          end
        end

        override :perform
        def perform(start_id, end_id)
          build_ids = CiBuild.retried.security_related.in_range(start_id, end_id).pluck(:id)
          updated_count = SecurityScan.by_build_ids(build_ids).update_all(latest: false)

          ::Gitlab::BackgroundMigration::Logger.info(
            {
              migrator: self.class.name,
              updated_count: updated_count
            }
          )
        end
      end
    end
  end
end
