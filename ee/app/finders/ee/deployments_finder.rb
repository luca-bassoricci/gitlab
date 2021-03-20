# frozen_string_literal: true

# WARNING: This finder does not check permissions!
#
# Arguments:
#   params:
#     group: Group model - Find deployments within a group (including subgroups)
#
# Note: If project and group is given at the same time, the project will have precedence.
# If project or group is missing, the finder will return empty resultset.
module EE
  module DeploymentsFinder
    extend ::Gitlab::Utils::Override

    private

    override :init_collection
    def init_collection
      if params[:project].present?
        super
      elsif params[:group].present?
        ::Deployment.for_project(::Project.in_namespace(params[:group].self_and_descendants))
      else
        ::Deployment.none
      end
    end

    override :by_environment
    def by_environment(items)
      if params[:project].present?
        super
      elsif params[:group].present? && params[:environment].present?
        items.for_environment_name(params[:environment])
      else
        super
      end
    end
  end
end
