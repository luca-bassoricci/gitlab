# frozen_string_literal: true

module Security
  class DependencyListService
    SORT_BY_VALUES = %w(name packager severity).freeze
    SORT_VALUES = %w(asc desc).freeze
    FILTER_PACKAGE_MANAGERS_VALUES = %w(bundler yarn npm maven composer pip).freeze
    FILTER_VALUES = %w(all vulnerable).freeze

    # @param pipeline [Ci::Pipeline]
    # @param [Hash] params to sort and filter dependencies
    # @option params ['asc', 'desc'] :sort ('asc') Order
    # @option params ['name', 'packager', 'severity'] :sort_by ('name') Field to sort
    # @option params ['bundler', 'yarn', 'npm', 'maven', 'composer', 'pip'] :package_manager ('bundler') Field to filter
    # @option params ['all', 'vulnerable'] :filter ('all') Field to filter
    def initialize(pipeline:, params: {})
      @pipeline = pipeline
      @params = params
    end

    # @return [Array<Hash>] collection of found dependencies
    def execute
      collection = init_collection
      collection = filter_by_package_manager(collection)
      collection = filter_by_vulnerable(collection)
      sort(collection)
    end

    private

    attr_accessor :params, :pipeline

    def init_collection
      pipeline.dependency_list_report.dependencies
    end

    def filter_by_package_manager(collection)
      return collection unless params[:package_manager]

      collection.select do |dependency|
        params[:package_manager].include?(dependency[:package_manager])
      end
    end

    def filter_by_vulnerable(collection)
      return collection unless params[:filter] == 'vulnerable'

      collection.select do |dependency|
        dependency[:vulnerabilities].any?
      end
    end

    def sort(collection)
      case params[:sort_by]
      when 'packager'
        collection.sort_by! { |a| a[:packager] }
      when 'severity'
        sort_dependency_vulnerabilities_by_severity!(collection) if Feature.enabled?(:sort_dependency_vulnerabilities, @pipeline.project)
        sort_dependencies_by_severity!(collection)
      else
        collection.sort_by! { |a| a[:name] }
      end

      collection.reverse! if params[:sort] == 'desc'

      collection
    end

    def compare_severity_levels(level1, level2)
      ::Enums::Vulnerability.severity_levels[level2] <=> ::Enums::Vulnerability.severity_levels[level1]
    end

    def sort_dependency_vulnerabilities_by_severity!(collection)
      collection.each do |dependency|
        dependency[:vulnerabilities].sort! do |vulnerability1, vulnerability2|
          compare_severity_levels(vulnerability1[:severity], vulnerability2[:severity])
        end
      end
    end

    # vulnerabilities are already sorted by severity level so we can assume that first vulnerability in
    # vulnerabilities array will have highest severity
    def sort_dependencies_by_severity!(collection)
      collection.sort! do |dep_i, dep_j|
        level_i = dep_i.dig(:vulnerabilities, 0, :severity) || :info
        level_j = dep_j.dig(:vulnerabilities, 0, :severity) || :info
        compare_severity_levels(level_i, level_j)
      end
    end
  end
end
