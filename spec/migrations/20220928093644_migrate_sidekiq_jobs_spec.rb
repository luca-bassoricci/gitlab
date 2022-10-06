# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe MigrateSidekiqJobs do
  around do |example|
    Sidekiq.redis do |conn|
      conn.scan_each(match: "queue:*") { |key| conn.del key }
    end
    Sidekiq::Testing.disable!(&example)
  end

  def add_job(queue, payload)
    Sidekiq.redis do |conn|
      conn.lpush("queue:#{queue}", payload)
    end
  end

  describe '#up' do
    before do
      add_job('email_receiver', '{"jid": 1, "class": "EmailReceiverWorker"}')
      add_job('email_receiver', '{"jid": 2, "class": "EmailReceiverWorker"}')
      add_job('export_csv', '{"jid": 3, "class": "ExportCsvWorker"}')
      add_job('export_csv', '{"jid": 4, "class": "ExportCsvWorker"}')
      add_job('default', '{"jid": 5, "class": "DeleteUserWorker"}')
    end

    it 'migrates the jobs to default queue' do
      migrate!
      queues = []
      Sidekiq.redis do |conn|
        conn.scan_each(match: "queue:*") { |key| queues << key }
      end

      expect(queues).not_to include('queue:email_receiver', 'queue:export_csv')
      expect(queues).to include('queue:default')

      Sidekiq.redis do |conn|
        jobs = conn.lrange('queue:default', 0, -1)
        expect(jobs).to include(
          '{"jid": 1, "class": "EmailReceiverWorker"}',
          '{"jid": 2, "class": "EmailReceiverWorker"}',
          '{"jid": 3, "class": "ExportCsvWorker"}',
          '{"jid": 4, "class": "ExportCsvWorker"}',
          '{"jid": 5, "class": "DeleteUserWorker"}')
      end
    end
  end
end
