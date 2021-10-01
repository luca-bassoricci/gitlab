# frozen_string_literal: true

module QA
  module Support
    class PageErrorChecker
      def self.report!(page)
        severe_errors = logs(page).select { |log| log.level == 'SEVERE' }
        return if severe_errors.none?

        report = error_report_for(severe_errors)
        raise "There #{severe_errors.count == 1 ? 'was' : 'were'} #{severe_errors.count} "\
          "error#{severe_errors.count == 1 ? '' : 's'}:\n\n#{report}\n\n"\
          "Username: #{Runtime::User.username}\n\n"\
          "Path: #{page.current_path}\n\n"\
          "Group: #{Runtime::Namespace.sandbox_name}"
      end

      def self.check_page_for_error_code(page)
        # Test for 404 img alt
        return 404 if Nokogiri::HTML.parse(page.html).xpath("//img").map { |t| t[:alt] }.first.eql?('404')

        # 500 error page in header surrounded by newlines, try to match
        five_hundred_test = Nokogiri::HTML.parse(page.html).xpath("//h1").map.first
        unless five_hundred_test.nil?
          return 500 if five_hundred_test.text.include?('500')
        end
        # GDK shows backtrace rather than error page
        return 500 if Nokogiri::HTML.parse(page.html).xpath("//body//section").map { |t| t[:class] }.first.eql?('backtrace')

        0
      end

      def self.error_report_for(logs)
        logs
            .map(&:message)
            .map { |message| message.gsub('\\n', "\n") }
      end

      def self.logs(page)
        page.driver.browser.manage.logs.get(:browser)
      end
    end
  end
end
