# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Memory::UploadAndCleanupReports, :aggregate_failures do
  let(:uploader) { instance_double(Gitlab::Memory::ReportUploader) }

  describe '#initalize' do
    let(:reports_path) { '/path/to/reports' }

    context 'when sleep_time_seconds is passed through the environment' do
      before do
        stub_env('GITLAB_DIAGNOSTIC_REPORTS_UPLOADER_SLEEP_S', '600')
      end

      it 'initializes with these settings' do
        upload_and_cleanup = described_class.new(uploader: uploader, reports_path: reports_path)

        expect(upload_and_cleanup.sleep_time_seconds).to eq(600)
      end
    end

    context 'when sleep_time_seconds is passed through the initializer' do
      it 'initializes with these settings' do
        upload_and_cleanup = described_class.new(uploader: uploader, reports_path: reports_path, sleep_time_seconds: 60)

        expect(upload_and_cleanup.sleep_time_seconds).to eq(60)
      end
    end

    context 'when `sleep_time_seconds` is not passed' do
      it 'initialized with the default' do
        upload_and_cleanup = described_class.new(uploader: uploader, reports_path: reports_path)

        expect(upload_and_cleanup.sleep_time_seconds).to eq(described_class::DEFAULT_SLEEP_TIME_SECONDS)
      end
    end
  end

  describe '#call' do
    let(:upload_and_cleanup) do
      described_class.new(sleep_time_seconds: 600, reports_path: dir, uploader: uploader).tap do |instance|
        allow(instance).to receive(:loop).and_yield
        allow(instance).to receive(:sleep)
      end
    end

    let(:dir) { Dir.mktmpdir }

    after do
      FileUtils.remove_entry(dir)
    end

    context 'when `gitlab_diagnostic_reports_uploader` ops FF is enabled' do
      let(:reports_count) { 3 }

      let(:reports) do
        (1..reports_count).map do |i|
          Tempfile.new("report.1.worker_#{i}.#{Time.current.to_i}.json", dir)
        end
      end

      it 'invokes the uploader and cleans the files' do
        expect(Gitlab::AppLogger)
          .to receive(:info)
          .with(hash_including(:pid, :worker_id,
                               message: "Diagnostic reports",
                               class: 'Gitlab::Memory::UploadAndCleanupReports',
                               perf_report_status: 'started'))

        reports.each do |report|
          expect(upload_and_cleanup.uploader).to receive(:upload).with(report.path)
        end

        expect { upload_and_cleanup.call }
          .to change { Dir.entries(dir).count { |e| e.match(/report.*/) } }
          .from(reports_count).to(0)
      end

      context 'when there is an exception' do
        let(:report) { Tempfile.new("report.1.worker_1.#{Time.current.to_i}.json", dir) }

        it 'logs it and does not crash the loop' do
          expect(upload_and_cleanup.uploader)
            .to receive(:upload)
            .with(report.path)
            .and_raise(StandardError, 'Error Message')

          expect(Gitlab::ErrorTracking)
            .to receive(:log_exception)
            .with(an_instance_of(StandardError),
                  hash_including(:pid, :worker_id, message: "Diagnostic reports",
                                                   class: 'Gitlab::Memory::UploadAndCleanupReports'))

          expect { upload_and_cleanup.call }.not_to raise_error
        end
      end
    end

    context 'when `gitlab_diagnostic_reports_uploader` ops FF is disabled' do
      before do
        stub_feature_flags(gitlab_diagnostic_reports_uploader: false)
        Tempfile.new("report.1.worker_1.#{Time.current.to_i}.json", dir)
      end

      it 'does not upload and remove any files' do
        expect(upload_and_cleanup.uploader).not_to receive(:upload)

        expect { upload_and_cleanup.call }.not_to change { Dir.entries(dir).count }
      end
    end
  end
end
