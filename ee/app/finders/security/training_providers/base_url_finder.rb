# frozen_string_literal: true

module Security
  module TrainingProviders
    class BaseUrlFinder
      include Gitlab::Utils::StrongMemoize
      include ReactiveCaching

      self.reactive_cache_refresh_interval = 1.minute
      self.reactive_cache_lifetime = 10.minutes
      self.reactive_cache_work_type = :external_dependency

      def initialize(project, provider, identifier_external_id, language = nil)
        @project = project
        @provider = provider
        @identifier_external_id = identifier_external_id.split('-').last
        @identifier = identifier_external_id # we need this to hold the pre-parsed data
        @language = language
      end

      def execute
        if response_url.nil?
          { name: provider.name, url: response_url, status: "pending" }
        elsif response_url[:url]
          { name: provider.name, url: response_url[:url], status: "completed", identifier: @identifier }
        end
      end

      def self.from_cache(id)
        project_id, provider_id, identifier_external_id, language = id.split('-')

        project = Project.find(project_id)
        provider = ::Security::TrainingProvider.find(provider_id)

        new(project, provider, identifier_external_id, language)
      end

      private

      attr_reader :project, :provider, :identifier_external_id, :language

      def response_url
        strong_memoize(:response_url) do
          with_reactive_cache(full_url) {|data| data}
        end
      end

      def full_url
        raise NotImplementedError, 'full_url must be overwritten to return training url'
      end

      # Required for ReactiveCaching; Usage overridden by
      # self.reactive_cache_worker_finder
      def id
        "#{project.id}-#{provider.id}-#{identifier_external_id}#{language_id_suffix}"
      end

      def language_id_suffix
        "-#{@language}" if @language
      end
    end
  end
end
