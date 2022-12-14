# frozen_string_literal: true

module Gitlab
  module IncidentManagement
    def self.oncall_schedules_available?(project)
      project.feature_available?(:oncall_schedules)
    end

    def self.escalation_policies_available?(project)
      oncall_schedules_available?(project) &&
        project.feature_available?(:escalation_policies) &&
        ::Feature.enabled?(:escalation_policies_mvc, project, default_enabled: :yaml)
    end
  end
end
