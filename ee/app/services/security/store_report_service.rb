# frozen_string_literal: true

module Security
  # Service for storing a given security report into the database.
  #
  class StoreReportService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :pipeline, :report, :project

    def initialize(pipeline, report)
      @pipeline = pipeline
      @report = report
      @project = @pipeline.project
    end

    def execute
      # Ensure we're not trying to insert data twice for this report
      return error("#{@report.type} report already stored for this pipeline, skipping...") if executed?

      with_diff = true

      if with_diff
        previous_report = get_previous_report

        report_diff = Security::CompareReportsSastService.new(previous_report, report, project).execute

        # flag the fixed
        report_diff.fixed.each do |occurrence|
          occurrence.flag_as_fixed!(@pipeline)
        end

        # Update the existing with their new location
        report_diff.existing.each do |occurrence|
          occurrence.update_location!(@pipeline)
          # Create occurrence_pipeline for this pipeline
          create_vulnerability_pipeline_object(occurrence, pipeline)
        end

        # Store only the new
        report_diff.added.each do |occurrence|
          create_vulnerability(occurrence)
        end
      else
        create_all_vulnerabilities!
      end

      success
    end

    private


    # TODO: replace with first-class Report entity when available
    # rubocop: disable CodeReuse/ActiveRecord
    def get_previous_report
      previous_pipeline_with_report = project.vulnerabilities.where(report_type: report.type).order(id: :desc).first&.pipelines&.newest_first&.first

      previous_report = ::Gitlab::Ci::Reports::Security::Report.new(report.type, previous_pipeline_with_report&.sha)

      return previous_report unless previous_pipeline_with_report

      previous_pipeline_with_report.vulnerabilities.where(report_type: report.type).includes(:identifiers, :scanner).each do |occurrence|
        previous_report.add_occurrence(Gitlab::Ci::Reports::Security::Occurrence.from_database(occurrence))
      end

      previous_report
    end

    def executed?
      pipeline.vulnerabilities.report_type(@report.type).any?
    end

    def create_all_vulnerabilities!
      @report.occurrences.each do |occurrence|
        create_vulnerability(occurrence)
      end
    end

    def create_vulnerability(occurrence)
      vulnerability = create_or_find_vulnerability_object(occurrence)

      occurrence.identifiers.map do |identifier|
        create_vulnerability_identifier_object(vulnerability, identifier)
      end

      create_vulnerability_pipeline_object(vulnerability, pipeline)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def create_or_find_vulnerability_object(occurrence)
      find_params = {
        scanner: scanners_objects[occurrence.scanner.key],
        primary_identifier: identifiers_objects[occurrence.primary_identifier.key],
        location_fingerprint: occurrence.location.fingerprint
      }

      create_params = occurrence.to_hash
        .except(:compare_key, :identifiers, :location, :scanner) # rubocop: disable CodeReuse/ActiveRecord

      begin
        project.vulnerabilities
          .create_with(create_params)
          .find_or_create_by!(find_params)
      rescue ActiveRecord::RecordNotUnique
        project.vulnerabilities.find_by!(find_params)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def create_vulnerability_identifier_object(vulnerability, identifier)
      vulnerability.occurrence_identifiers.find_or_create_by!( # rubocop: disable CodeReuse/ActiveRecord
        identifier: identifiers_objects[identifier.key])
    rescue ActiveRecord::RecordNotUnique
    end

    def create_vulnerability_pipeline_object(vulnerability, pipeline)
      vulnerability.occurrence_pipelines.find_or_create_by!(pipeline: pipeline) # rubocop: disable CodeReuse/ActiveRecord
    rescue ActiveRecord::RecordNotUnique
    end

    def scanners_objects
      strong_memoize(:scanners_objects) do
        @report.scanners.map do |key, scanner|
          [key, existing_scanner_objects[key] || project.vulnerability_scanners.build(scanner.to_hash)]
        end.to_h
      end
    end

    def all_scanners_external_ids
      @report.scanners.values.map(&:external_id)
    end

    def existing_scanner_objects
      strong_memoize(:existing_scanner_objects) do
        project.vulnerability_scanners.with_external_id(all_scanners_external_ids).map do |scanner|
          [scanner.external_id, scanner]
        end.to_h
      end
    end

    def identifiers_objects
      strong_memoize(:identifiers_objects) do
        @report.identifiers.map do |key, identifier|
          [key, existing_identifiers_objects[key] || project.vulnerability_identifiers.build(identifier.to_hash)]
        end.to_h
      end
    end

    def all_identifiers_fingerprints
      @report.identifiers.values.map(&:fingerprint)
    end

    def existing_identifiers_objects
      strong_memoize(:existing_identifiers_objects) do
        project.vulnerability_identifiers.with_fingerprint(all_identifiers_fingerprints).map do |identifier|
          [identifier.fingerprint, identifier]
        end.to_h
      end
    end
  end
end
