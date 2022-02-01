# frozen_string_literal: true

module Auth
  class ProvisionedUsersFinder < UsersFinder
    extend ::Gitlab::Utils::Override

    private

    override :base_scope
    def base_scope
      group_id = params[:provisioning_group_id]
      raise "Provisioning group is required for ProvisionedUsersFinder" unless group_id

      User.provisioned_by_group(group_id).order_id_desc
    end

    override :by_search
    def by_search(users)
      return users unless params[:search].present?

      users.search(params[:search], with_private_emails: true)
    end
  end
end
