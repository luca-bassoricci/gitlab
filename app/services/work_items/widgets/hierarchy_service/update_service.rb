# frozen_string_literal: true

module WorkItems
  module Widgets
    module HierarchyService
      class UpdateService < WorkItems::Widgets::HierarchyService::BaseService
        def before_update_in_transaction(params:)
          return unless params.present?

          result = handle_hierarchy_changes(params)

          raise WidgetError, result[:message] if result[:status] == :error
        end
      end
    end
  end
end
