# frozen_string_literal: true

class PopulateExtensionInMainIndex < Elastic::Migration
  # include Elastic::MigrationHelper

  batched!
  throttle_delay 1.minute

  MAX_ATTEMPTS_PER_SLICE = 30

  def migrate
    if migration_state[:slice].blank?
      options = {
        slice: 0,
        retry_attempt: 0,
        max_slices: number_of_shards
      }

      set_migration_state(options)

      return
    end

    retry_attempt = migration_state[:retry_attempt].to_i
    slice = migration_state[:slice]
    task_id = migration_state[:task_id]
    max_slices = migration_state[:max_slices]

    if retry_attempt >= MAX_ATTEMPTS_PER_SLICE
      fail_migration_halt_error!(retry_attempt: retry_attempt)
      return
    end

    return unless slice < max_slices

    if task_id
      log "Checking update_by_query status for slice:#{slice} | task_id:#{task_id}"

      if task_completed?(task_id: task_id)
        log "Update is completed for slice:#{slice} | task_id:#{task_id}"

        set_migration_state(
          slice: slice + 1,
          task_id: nil,
          retry_attempt: 0, # We reset retry_attempt for a next slice
          max_slices: max_slices
        )
      else
        log "Update is still in progress for slice:#{slice} | task_id:#{task_id}"
      end

      return
    end

    log "Launching update_by_query for slice:#{slice} | max_slices:#{max_slices}"

    task_id = update_by_query(slice: slice, max_slices: max_slices)

    log "Update for slice:#{slice} | max_slices:#{max_slices} is started with task_id:#{task_id}"

    set_migration_state(
      slice: slice,
      task_id: task_id,
      max_slices: max_slices
    )
  rescue StandardError => e
    log "Update failed, increasing migration_state for slice:#{slice} retry_attempt:#{retry_attempt} error:#{e.message}"

    set_migration_state(
      slice: slice,
      task_id: nil,
      retry_attempt: retry_attempt + 1,
      max_slices: max_slices
    )

    raise e
  end

  def completed?
    helper.refresh_index(index_name: index_name)

    query = {
      size: 0,
      aggs: {
        blobs: {
          filter: documents_missing_extension_field
        }
      }
    }

    results = client.search(index: index_name, body: query)
    doc_count = results.dig('aggregations', 'blobs', 'doc_count')

    log "Checking if there are documents without extension field: #{doc_count} documents left"

    doc_count == 0
  end

  private

  def index_name
    helper.target_index_name
  end

  def number_of_shards
    helper.get_settings(index_name: index_name).dig('number_of_shards').to_i
  end

  def update_by_query(slice:, max_slices:)
    query = {
      slice: {
        id: slice,
        max: max_slices
      },
      query: {
        term: {
          type: 'blob'
        }
      },
      script: {
        lang: 'painless',
        source: "if (ctx._source.blob.file_name != null) {" \
                "def arr = ctx._source.blob.file_name.splitOnToken('.');" \
                "if (arr.length > 1) {" \
                "ctx._source.blob.extension = arr[arr.length-1]" \
                "} else { ctx._source.blob.extension = null }}"
      }
      # "source": "if (ctx._source.blob.file_name != null) { def arr = ctx._source.blob.file_name.splitOnToken('.'); if (arr.length > 1) {ctx._source.blob.extension = arr[arr.length-1] } else { ctx._source.blob.extension = null }}"
      # "source": "if (ctx._source.blob.file_name != null) { def arr = ctx._source.blob.file_name.splitOnToken('.'); if (arr.length > 1) {ctx._source.blob.extension = arr[arr.length-1] } else { ctx._source.blob.extension = null }} else { ctx._source.blob.extension = null }"
    }

    response = client.update_by_query(index: index_name, body: query, wait_for_completion: false)
    response['task']
  end

  def task_completed?(task_id:)
    response = helper.task_status(task_id: task_id)
    completed = response['completed']

    return false unless completed

    stats = response['response']

    if stats['failures'].present?
      log_raise "Update is failed with #{stats['failures']}"
    end

    true
  end

  def documents_missing_extension_field
    {
      bool: {
        must: {
          term: {
            type: 'blob'
          }
        },
        must_not: {
          exists: {
            field: 'blob.extension'
          }
        }
      }
    }
  end
end
