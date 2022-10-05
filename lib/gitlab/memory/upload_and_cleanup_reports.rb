# frozen_string_literal: true

module Gitlab
  module Memory
    class UploadAndCleanupReports
      DEFAULT_SLEEP_TIME_SECONDS = 900 # 15 minutes

      def initialize(
        uploader:,
        reports_path:,
        sleep_time_seconds: ENV['GITLAB_DIAGNOSTIC_REPORTS_UPLOADER_SLEEP_S']&.to_i || DEFAULT_SLEEP_TIME_SECONDS)

        @uploader = uploader
        @reports_path = reports_path
        @sleep_time_seconds = sleep_time_seconds
        @alive = true
      end

      attr_reader :uploader, :reports_path, :sleep_time_seconds

      def call
        log_started

        loop do
          sleep(sleep_time_seconds)

          next unless Feature.enabled?(:gitlab_diagnostic_reports_uploader, type: :ops)

          files_to_process.each { |path| upload_and_cleanup!(path) }
        end
      end

      private

      def upload_and_cleanup!(path)
        uploader.upload(path)
      rescue StandardError, Errno::ENOENT => error
        log_exception(error)
      ensure
        cleanup!(path)
      end

      def cleanup!(path)
        File.unlink(path) if File.exist?(path)
      rescue Errno::ENOENT
        # Path does not exist: Ignore. We already check `File.exist?`. Rescue to be extra safe.
      end

      def files_to_process
        Dir.entries(reports_path)
          .map { |path| File.join(reports_path, path) }
          .select { |path| File.file?(path) }
      end

      def log_started
        Gitlab::AppLogger.info(log_labels.merge(perf_report_status: "started"))
      end

      def log_exception(error)
        Gitlab::ErrorTracking.log_exception(error, log_labels)
      end

      def log_labels
        {
          message: "Diagnostic reports",
          class: self.class.name,
          pid: $$,
          worker_id: worker_id
        }
      end

      def worker_id
        ::Prometheus::PidProvider.worker_id
      end
    end
  end
end
