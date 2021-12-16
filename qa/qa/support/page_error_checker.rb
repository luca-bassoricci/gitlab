# frozen_string_literal: true

module QA
  module Support
    class PageErrorChecker
      def self.report!(page, error_code)
        # if severe_errors.none? || !page.driver.options[:browser].eq(:chrome)
        #
        case QA::Runtime::Env.browser
        when :chrome
          severe_errors = logs(page).select { |log| log.level == 'SEVERE' }
          report = if !severe_errors.none?
                     "There #{severe_errors.count == 1 ? 'was' : 'were'} #{severe_errors.count} "\
                     "error#{severe_errors.count == 1 ? '' : 's'}:\n\n#{error_report_for(severe_errors)}"
                   else
                     status_code_report(error_code)
                   end
        else
          report = status_code_report(error_code)
        end

        raise "#{report}\n\n"\
          "Username: #{Runtime::User.username}\n\n"\
          "Path: #{page.current_path}\n\n"\
          "Group: #{Runtime::Namespace.sandbox_name}"
      end

      def self.status_code_report(error_code)
        "Status code #{error_code} found"
      end

      def self.check_page_for_error_code(page)
        error_code = 0
        # Test for 404 img alt
        error_code = 404 if Nokogiri::HTML.parse(page.html).xpath("//img").map { |t| t[:alt] }.first.eql?('404')

        # 500 error page in header surrounded by newlines, try to match
        five_hundred_test = Nokogiri::HTML.parse(page.html).xpath("//h1").map.first
        unless five_hundred_test.nil?
          error_code = 500 if five_hundred_test.text.include?('500')
        end
        # GDK shows backtrace rather than error page
        error_code = 500 if Nokogiri::HTML.parse(page.html).xpath("//body//section").map { |t| t[:class] }.first.eql?('backtrace')

        unless error_code == 0
          report!(page, error_code)
        end
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
