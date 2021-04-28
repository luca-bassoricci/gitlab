# frozen_string_literal: true

module TodosDestroyer
  class ConfidentialEpicWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :todos_destroyer
    feature_category :epics
    tags :exclude_from_kubernetes

    def perform(epic_id)
      return unless epic_id

      ::Todos::Destroy::ConfidentialEpicService.new(epic_id: epic_id).execute
    end
  end
end
