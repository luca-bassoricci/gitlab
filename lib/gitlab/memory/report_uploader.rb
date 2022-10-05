# frozen_string_literal: true

module Gitlab
  module Memory
    class ReportUploader
      def initialize(gcs_key:, gcs_project:, gcs_bucket:)
        @gcs_bucket = gcs_bucket
        @fog = Fog::Storage::Google.new(google_project: gcs_project, google_json_key_location: gcs_key)
      end

      def upload(path)
        log_upload_requested(path)
        start_monotonic_time = Gitlab::Metrics::System.monotonic_time

        File.open(path.to_s) { |file| @fog.put_object(@gcs_bucket, File.basename(path), file) }

        duration_s = Gitlab::Metrics::System.monotonic_time - start_monotonic_time
        log_upload_success(path, duration_s)
      rescue StandardError, Errno::ENOENT => error
        log_exception(error)
      end

      private

      def cleanup!(path)
        File.unlink(path) if File.exist?(path)
      rescue Errno::ENOENT
        # Path does not exist: Ignore. We already check `File.exist?`. Rescue to be extra safe.
      end

      def log_upload_requested(path)
        Gitlab::AppLogger.info(log_labels.merge(perf_report_status: 'upload requested', perf_report_path: path))
      end

      def log_upload_success(path, duration_s)
        Gitlab::AppLogger.info(log_labels.merge(perf_report_status: 'upload success', perf_report_path: path,
                                                duration_s: duration_s))
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
