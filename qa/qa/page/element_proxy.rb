module Qa
  module Page
    class SessionProxy
      attr_reader :context

      def initialize(context)
        @context = context
      end

      def find(name, **kwargs)
        ElementProxy.new(context, name, **kwargs)
      end
    end

    class ElementProxy
      attr_reader :context, :options, :name, :element

      # @param context [Capybara::Session || Qa::Page::ElementProxy]
      # @param name [String] capybara selector
      # @param [Hash] options locator options for Capybara
      def initialize(context, name, **options)
        @context = context
        @options = options
        @name = name
        @element = nil
      end

      def find(name, **kwargs)
        ElementProxy.new(self, name, **kwargs)
      end

      def method_missing(method, *args, &block)
        execute { locate.element.send(method, *args, &block) }
      end

      protected

      def execute(&block)
        begin
          block.call
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          locate(force: true)
          block.call
        end
      end

      def locate(force: false)
        return self if @element && !force
        if context.is_a?(Capybara::Session)
          @element = context.find(name, **options)
        elsif context.is_a?(Qa::Page::ElementProxy)
          parent = context.locate(force: force)
          @element = parent.element.find(name, **options)
        end
        return self
      end
    end
  end
end
