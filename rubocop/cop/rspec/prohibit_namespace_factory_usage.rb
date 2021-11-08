# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # This cop checks for `create(:namespace, ...)` or build(:namespace, ...)
      # usage in specs. These are not allowed because we are deprecating
      # untyped Namespace in favour of Group, UserNamespace and ProjectNamespace
      # See https://gitlab.com/gitlab-org/gitlab/-/issues/341447
      #
      # @example
      #
      #   # bad
      #   let(:namespace) { create(:namespace, name: "Mystery namespace") }
      #
      #   # bad
      #   let(:namespace) { build(:namespace, name: "Mystery namespace") }
      #
      #   # good
      #   create(:user_namespace, name: "Clearly a user namespace")
      #
      #   # good
      #   let(:group) { build(:group, name: "My wonderful group") }
      #
      #   # good
      #   let(:namespace) { build(:project_namespace) }

      class ProhibitNamespaceFactoryUsage < RuboCop::Cop::Cop
        MESSAGE = 'Do not use the `namespace` factory, use `user_namespace`, `group`, or `project_namespace` instead.'

        def_node_search :build_create_namespace?, <<~PATTERN
          (send nil? {:build | :create} (sym :namespace) ...)
        PATTERN

        def on_send(node)
          if build_create_namespace?(node)
            add_offense(node, location: :expression, message: MESSAGE)
          end
        end
      end
    end
  end
end
