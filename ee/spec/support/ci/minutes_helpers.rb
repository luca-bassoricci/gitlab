# frozen_string_literal: true

module Ci
  module MinutesHelpers
    # TODO: Remove with https://gitlab.com/gitlab-org/gitlab/-/issues/277452
    def set_ci_minutes_used(namespace, minutes)
      if namespace.namespace_statistics
        namespace.namespace_statistics.update!(shared_runners_seconds: minutes.minutes)
      else
        namespace.create_namespace_statistics(shared_runners_seconds: minutes.minutes)
      end

      ::Ci::Minutes::NamespaceMonthlyUsage
        .find_or_create_current(namespace_id: namespace.id)
        .update!(amount_used: minutes)
    end
  end
end
