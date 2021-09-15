# frozen_string_literal: true

module Namespaces
  class ProjectNamespace < Namespace
    has_one :project, foreign_key: :project_namespace_id, inverse_of: :project_namespace

    def self.sti_name
      'Project'
    end

    def self.polymorphic_name
      'Namespaces::ProjectNamespace'
    end

    private

    # we're just borrowing project route and change the source
    def prepare_route
      return unless project
      return unless full_path_changed? || full_name_changed?

      self.route || build_route(source: self)
      self.route.path = project.build_full_path
      self.route.name = project.build_full_name
    end
  end
end
