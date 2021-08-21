# frozen_string_literal: true

# rubocop:disable Gitlab/ModuleWithInstanceVariables
module GrapePathHelpers
  module AllRoutes
    def decorated_routes
      # memoize so that construction of decorated routes happens once
      return @decorated_routes if @decorated_routes

      routes = {}

      all_routes
        .map { |r| DecoratedRoute.new(r) }
        .sort_by { |r| -r.dynamic_path_segments.count }
        .each do |route|
          route.helper_names.each do |helper_name|
            key = helper_name.to_sym

            routes[key] ||= []
            routes[key] << route
          end
        end

      @decorated_routes = routes
    end
  end

  module NamedRouteMatcher
    def method_missing(method_name, *args)
      return super unless Grape::API::Instance.decorated_routes[method_name]

      segments = args.first || {}

      return super unless segments.is_a?(Hash)

      requested_segments = segments.keys.map(&:to_s)

      route = Grape::API::Instance.decorated_routes[method_name].detect do |r|
        r.uses_segments_in_path_helper?(requested_segments)
      end

      if route
        route.send(method_name, *args)
      else
        super
      end
    end
    ruby2_keywords(:method_missing)

    def respond_to_missing?(method_name, _include_private = false)
      !Grape::API::Instance.decorated_routes[method_name].nil? || super
    end
  end
end
