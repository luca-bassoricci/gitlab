# frozen_string_literal: true

# Include atomic internal id generation scheme for a model
#
# This allows us to atomically generate internal ids that are
# unique within a given scope.
#
# For example, let's generate internal ids for Issue per Project:
# ```
# class Issue < ApplicationRecord
#   has_internal_id :iid, scope: :project, init: ->(s) { s.project.issues.maximum(:iid) }
# end
# ```
#
# This generates unique internal ids per project for newly created issues.
# The generated internal id is saved in the `iid` attribute of `Issue`.
#
# This concern uses InternalId records to facilitate atomicity.
# In the absence of a record for the given scope, one will be created automatically.
# In this situation, the `init` block is called to calculate the initial value.
# In the example above, we calculate the maximum `iid` of all issues
# within the given project.
#
# Note that a model may have more than one internal id associated with possibly
# different scopes.
module AtomicInternalId
  extend ActiveSupport::Concern

  class_methods do
    def internal_id_scopes
      @internal_id_scopes ||= []
    end

    def has_internal_id(column, scope:, init:, presence: true) # rubocop:disable Naming/PredicateName
      # We require init here to retain the ability to recalculate in the absence of a
      # InternaLId record (we may delete records in `internal_ids` for example).
      raise "has_internal_id requires a init block, none given." unless init

      self.internal_id_scopes << scope

      before_validation :"ensure_#{scope}_#{column}!", on: :create
      validates column, presence: presence

      define_method("ensure_#{scope}_#{column}!") do
        scope_value = association(scope).reader
        value = read_attribute(column)

        return value unless scope_value

        scope_attrs = { scope_value.class.table_name.singularize.to_sym => scope_value }
        usage = self.class.table_name.to_sym

        # We don't have a value yet and use a InternalId record to generate
        # the next value.
        InternalId.generate_next(self, scope_attrs, usage, init).tap do |value|
          write_attribute(column, value)
        end
      end

      define_method("#{column}=") do |value|
        super(value).tap do
          self.class.internal_id_scopes.each do |scope|
            send("track_#{column}_by_#{scope}") # rubocop: disable GitlabSecurity/PublicSend
          end
        end
      end

      define_method("track_#{column}_by_#{scope}") do
        scope_value = association(scope).reader
        value = read_attribute(column)

        return value unless scope_value

        scope_attrs = { scope_value.class.table_name.singularize.to_sym => scope_value }
        usage = self.class.table_name.to_sym

        InternalId.track_greatest(self, scope_attrs, usage, value, init)
      end

      define_method("reset_#{scope}_#{column}") do
        if value = read_attribute(column)
          scope_value = association(scope).reader
          scope_attrs = { scope_value.class.table_name.singularize.to_sym => scope_value }
          usage = self.class.table_name.to_sym

          if InternalId.reset(self, scope_attrs, usage, value)
            write_attribute(column, nil)
          end
        end

        read_attribute(column)
      end
    end
  end
end
