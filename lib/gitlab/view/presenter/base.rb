# frozen_string_literal: true

module Gitlab
  module View
    module Presenter
      CannotOverrideMethodError = Class.new(StandardError)

      module Base
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::DelegatorOverride

        include Gitlab::Routing
        include Gitlab::Allowable

        delegator_override_with Gitlab::Routing.url_helpers # TODO: Remove `Gitlab::Routing` inclusion as it could override many methods in Active Record model.

        attr_reader :subject

        delegator_override :can?
        def can?(user, action, overridden_subject = nil)
          super(user, action, overridden_subject || subject)
        end

        # delegate all #can? queries to the subject
        delegator_override :declarative_policy_delegate
        def declarative_policy_delegate
          subject
        end

        delegator_override :present
        def present(**attributes)
          self
        end

        def url_builder
          Gitlab::UrlBuilder.instance
        end

        def is_a?(type)
          super || subject.is_a?(type)
        end

        delegator_override :web_url
        def web_url
          url_builder.build(subject)
        end

        def web_path
          url_builder.build(subject, only_path: true)
        end

        class_methods do
          def presenter?
            true
          end

          def presents(name, target_klass = nil)
            define_method(name) { subject }
            delegator_target(target_klass) if respond_to?(:delegator_target)
          end
        end
      end
    end
  end
end
