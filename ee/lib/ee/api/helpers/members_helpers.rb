# frozen_string_literal: true

module EE
  module API
    module Helpers
      module MembersHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        prepended do
          params :optional_filter_params_ee do
            optional :with_saml_identity, type: Grape::API::Boolean, desc: "List only members with linked SAML identity"
          end
        end

        # rubocop: disable CodeReuse/ActiveRecord
        override :retrieve_members
        def retrieve_members(source, params:, deep: false)
          members = super
          members = members.includes(user: :user_highest_role)

          if can_view_group_identity?(source)
            members = members.includes(user: :group_saml_identities)
            if params[:with_saml_identity] && source.saml_provider
              members = members.with_saml_identity(source.saml_provider)
            end
          end

          members
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def can_view_group_identity?(members_source)
          can?(current_user, :read_group_saml_identity, members_source)
        end

        override :create_member
        def create_member(current_user, user, source, params)
          member = source.add_user(user, params[:access_level], current_user: current_user, expires_at: params[:expires_at])

          return false unless member

          log_audit_event(member) if member.persisted? && member.valid?

          member
        end

        def find_member(params)
          source = find_source(:group, params.delete(:id))
          authorize! :override_group_member, source

          source.members.by_user_id(params[:user_id]).first
        end

        def present_member(updated_member)
          if updated_member.valid?
            present updated_member, with: ::API::Entities::Member
          else
            render_validation_error!(updated_member)
          end
        end

        def log_audit_event(member)
          ::AuditEventService.new(
            current_user,
            member.source,
            action: :create
          ).for_member(member).security_event
        end

        def paginate_billable_from_user_ids(user_ids)
          paginated = paginate(::Kaminari.paginate_array(user_ids.sort))

          users_as_hash = ::User.id_in(paginated).index_by(&:id)

          # map! ensures same paginatable array is manipulated
          # instead of creating a new non-paginatable array
          paginated.map! { |user_id| users_as_hash[user_id] }
        end
      end
    end
  end
end
