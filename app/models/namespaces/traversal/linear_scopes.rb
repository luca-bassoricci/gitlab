# frozen_string_literal: true

module Namespaces
  module Traversal
    module LinearScopes
      extend ActiveSupport::Concern

      class_methods do
        # When filtering namespaces by the traversal_ids column to compile a
        # list of namespace IDs, it can be faster to reference the ID in
        # traversal_ids than the primary key ID column.
        def as_ids
          return super unless use_traversal_ids?

          select(Arel.sql('namespaces.traversal_ids[array_length(namespaces.traversal_ids, 1)]').as('id'))
        end

        def roots
          return super unless use_traversal_ids_roots?

          root_ids = all.select("#{quoted_table_name}.traversal_ids[1]").distinct
          unscoped.where(id: root_ids)
        end

        def self_and_ancestors(include_self: true, upto: nil, hierarchy_order: nil)
          return super unless use_traversal_ids_for_ancestor_scopes?

          base_scope = all
            .reselect('namespaces.traversal_ids')
            .unscope(where: [:type])
          base_cte = Gitlab::SQL::CTE.new(:base_ancestors_cte, base_scope, materialized: false)

          unnest = if include_self
                     base_cte.table[:traversal_ids]
                   else
                     base_cte_traversal_ids = 'base_ancestors_cte.traversal_ids'
                     Arel.sql("#{base_cte_traversal_ids}[1:array_length(#{base_cte_traversal_ids},1)-1]")
                   end

          ancestor_subselect = "select DISTINCT #{unnest_func(unnest).to_sql} from base_ancestors_cte"
          ancestors_join = "INNER JOIN (#{ancestor_subselect}) AS ancestors(ancestor_id) ON namespaces.id = ancestors.ancestor_id"

          namespaces = Arel::Table.new(:namespaces)

          records = unscoped
            .with(base_cte.to_arel)
            .distinct
            .typeless
            .from(namespaces)
            .joins(ancestors_join)
            .order_by_depth(hierarchy_order)

          if upto
            upto_ancestor_ids = unscoped.where(id: upto).select(unnest_func(Arel.sql('traversal_ids')))
            records = records.where.not(id: upto_ancestor_ids)
          end

          records
        end

        def self_and_ancestor_ids(include_self: true)
          return super unless use_traversal_ids_for_ancestor_scopes?

          self_and_ancestors(include_self: include_self).as_ids
        end

        def self_and_descendants(include_self: true)
          return super unless use_traversal_ids_for_descendants_scopes?

          if Feature.enabled?(:traversal_ids_btree, default_enabled: :yaml)
            self_and_descendants_with_comparison_operators(include_self: include_self)
          else
            records = self_and_descendants_with_duplicates_with_array_operator(include_self: include_self)
            distinct = records.select('DISTINCT on(namespaces.id) namespaces.*')
            distinct.normal_select
          end
        end

        def self_and_descendant_ids(include_self: true)
          return super unless use_traversal_ids_for_descendants_scopes?

          if Feature.enabled?(:traversal_ids_btree, default_enabled: :yaml)
            self_and_descendants_with_comparison_operators(include_self: include_self).as_ids
          else
            self_and_descendants_with_duplicates_with_array_operator(include_self: include_self)
              .select('DISTINCT namespaces.id')
          end
        end

        def self_and_hierarchy
          return super unless use_traversal_ids_for_self_and_hierarchy_scopes?

          unscoped.from_union([all.self_and_ancestors, all.self_and_descendants(include_self: false)])
        end

        def order_by_depth(hierarchy_order)
          return all unless hierarchy_order

          depth_order = hierarchy_order == :asc ? :desc : :asc

          all
            .select(Namespace.default_select_columns, 'array_length(traversal_ids, 1) as depth')
            .order(depth: depth_order, id: :asc)
        end

        # Produce a query of the form: SELECT * FROM namespaces;
        #
        # When we have queries that break this SELECT * format we can run in to errors.
        # For example `SELECT DISTINCT on(...)` will fail when we chain a `.count` c
        def normal_select
          unscoped.from(all, :namespaces)
        end

        private

        def use_traversal_ids?
          Feature.enabled?(:use_traversal_ids, default_enabled: :yaml)
        end

        def use_traversal_ids_roots?
          Feature.enabled?(:use_traversal_ids_roots, default_enabled: :yaml) &&
          use_traversal_ids?
        end

        def use_traversal_ids_for_ancestor_scopes?
          Feature.enabled?(:use_traversal_ids_for_ancestor_scopes, default_enabled: :yaml) &&
          use_traversal_ids?
        end

        def use_traversal_ids_for_descendants_scopes?
          Feature.enabled?(:use_traversal_ids_for_descendants_scopes, default_enabled: :yaml) &&
          use_traversal_ids?
        end

        def use_traversal_ids_for_self_and_hierarchy_scopes?
          Feature.enabled?(:use_traversal_ids_for_self_and_hierarchy_scopes, default_enabled: :yaml) &&
            use_traversal_ids?
        end

        def self_and_descendants_with_comparison_operators(include_self: true)
          base = all.select(:traversal_ids)
          base_cte = Gitlab::SQL::CTE.new(:descendants_base_cte, base, materialized: false)

          namespaces = Arel::Table.new(:namespaces)

          # Bound the search space to ourselves (optional) and descendants.
          #
          # WHERE next_traversal_ids_sibling(base_cte.traversal_ids) > namespaces.traversal_ids
          records = unscoped
            .distinct
            .with(base_cte.to_arel)
            .from([base_cte.table, namespaces])
            .where(next_sibling_func(base_cte.table[:traversal_ids]).gt(namespaces[:traversal_ids]))

          #   AND base_cte.traversal_ids <= namespaces.traversal_ids
          if include_self
            records.where(base_cte.table[:traversal_ids].lteq(namespaces[:traversal_ids]))
          else
            records.where(base_cte.table[:traversal_ids].lt(namespaces[:traversal_ids]))
          end
        end

        def next_sibling_func(*args)
          Arel::Nodes::NamedFunction.new('next_traversal_ids_sibling', args)
        end

        def unnest_func(*args)
          Arel::Nodes::NamedFunction.new('UNNEST', args)
        end

        def self_and_descendants_with_duplicates_with_array_operator(include_self: true)
          base_ids = select(:id)

          records = unscoped
            .from("namespaces, (#{base_ids.to_sql}) base")
            .where('namespaces.traversal_ids @> ARRAY[base.id]')

          if include_self
            records
          else
            records.where('namespaces.id <> base.id')
          end
        end
      end
    end
  end
end
