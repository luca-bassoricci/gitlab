# frozen_string_literal: true

RSpec.describe QA::Support::PageErrorChecker do
  describe '.report!' do
    context 'reports errors' do
      before do
        single_log = Class.new do
          def level
            'SEVERE'
          end
        end
        stub_const('SingleLog', single_log)
        one_error_mocked_logs = Class.new do
          def self.select
            [SingleLog]
          end
        end
        stub_const('OneErrorMockedLogs', one_error_mocked_logs)
        three_errors_mocked_logs = Class.new do
          def self.select
            [SingleLog, SingleLog, SingleLog]
          end
        end
        stub_const('ThreeErrorsMockedLogs', three_errors_mocked_logs)
        no_error_mocked_logs = Class.new do
          def self.select
            []
          end
        end
        stub_const('NoErrorMockedLogs', no_error_mocked_logs)
      end

      let(:page) { double(Capybara.page) }

      let(:expected_single_error) do
        "There was 1 error:\n\n"\
        "bar foo\n\n"\
        "Username: testuser\n\n"\
        "Path: /test/path\n\n"\
        "Group: testgroup"
      end

      let(:expected_multiple_error) do
        "There were 3 errors:\n\n"\
        "bar foo\n"\
        "foo\n"\
        "bar\n\n"\
        "Username: testuser\n\n"\
        "Path: /test/path\n\n"\
        "Group: testgroup"
      end

      it 'reports on 1 error' do
        allow(QA::Support::PageErrorChecker).to receive(:error_report_for).with([SingleLog]).and_return('bar foo')
        allow(QA::Support::PageErrorChecker).to receive(:logs).with(page).and_return(OneErrorMockedLogs)
        allow(page).to receive(:current_path).and_return('/test/path')
        allow(QA::Runtime::User).to receive(:username).and_return('testuser')
        allow(QA::Runtime::Namespace).to receive(:sandbox_name).and_return('testgroup')

        expect { QA::Support::PageErrorChecker.report!(page) }.to raise_error(RuntimeError, expected_single_error)
      end

      it 'reports on multiple errors' do
        allow(QA::Support::PageErrorChecker).to receive(:error_report_for)
            .with([SingleLog, SingleLog, SingleLog]).and_return("bar foo\nfoo\nbar")
        allow(QA::Support::PageErrorChecker).to receive(:logs).with(page).and_return(ThreeErrorsMockedLogs)
        allow(page).to receive(:current_path).and_return('/test/path')
        allow(QA::Runtime::User).to receive(:username).and_return('testuser')
        allow(QA::Runtime::Namespace).to receive(:sandbox_name).and_return('testgroup')

        expect { QA::Support::PageErrorChecker.report!(page) }.to raise_error(RuntimeError, expected_multiple_error)
      end

      it 'does not report on no errors' do
        allow(QA::Support::PageErrorChecker).to receive(:logs).with(page).and_return(NoErrorMockedLogs)

        expect { QA::Support::PageErrorChecker.report!(page) }.not_to raise_error
      end
    end
  end

  describe '.check_page_for_error_code' do
    require 'nokogiri'
    before do
      nokogiri_parse = Class.new do
        def self.parse(str)
          Nokogiri::HTML.parse(str)
        end
      end
      stub_const('NokogiriParse', nokogiri_parse)
    end
    let(:page) { double(Capybara.page) }
    let(:error_404_str) do
      "<div class=\"error\">"\
                             "<img src=\"404.png\" alt=\"404\" />"\
                          "</div>"
    end

    let(:error_500_str) { "<h1>   500   </h1>"}
    let(:backtrace_str) {"<body><section class=\"backtrace\">foo</section></body>"}
    let(:no_error_str) {"<body>no 404 or 500 or backtrace</body>"}

    it 'returns 404 if 404 found' do
      allow(page).to receive(:html).and_return(error_404_str)
      allow(Nokogiri::HTML).to receive(:parse).with(error_404_str).and_return(NokogiriParse.parse(error_404_str))

      expect(QA::Support::PageErrorChecker.check_page_for_error_code(page)).to eq(404)
    end
    it 'returns 500 if 500 found' do
      allow(page).to receive(:html).and_return(error_500_str)
      allow(Nokogiri::HTML).to receive(:parse).with(error_500_str).and_return(NokogiriParse.parse(error_500_str))

      expect(QA::Support::PageErrorChecker.check_page_for_error_code(page)).to eq(500)
    end
    it 'returns 500 if GDK backtrace found' do
      allow(page).to receive(:html).and_return(backtrace_str)
      allow(Nokogiri::HTML).to receive(:parse).with(backtrace_str).and_return(NokogiriParse.parse(backtrace_str))

      expect(QA::Support::PageErrorChecker.check_page_for_error_code(page)).to eq(500)
    end
    it 'returns 0 if no 404, 500 or backtrace found' do
      allow(page).to receive(:html).and_return(no_error_str)
      allow(Nokogiri::HTML).to receive(:parse).with(no_error_str).and_return(NokogiriParse.parse(no_error_str))

      expect(QA::Support::PageErrorChecker.check_page_for_error_code(page)).to eq(0)
    end
  end

  describe '.error_report_for' do
    before do
      logs_class_one = Class.new do
        def self.message
          'foo\\n'
        end
      end
      stub_const('LogOne', logs_class_one)
      logs_class_two = Class.new do
        def self.message
          'bar'
        end
      end
      stub_const('LogTwo', logs_class_two)
    end

    it 'returns error report array of log messages' do
      expect(QA::Support::PageErrorChecker.error_report_for([LogOne, LogTwo]))
          .to eq(%W(foo\n bar))
    end
  end

  describe '.logs' do
    before do
      logs_class = Class.new do
        def self.get(level)
          "logs at #{level} level"
        end
      end
      stub_const('Logs', logs_class)
      manage_class = Class.new do
        def self.logs
          Logs
        end
      end
      stub_const('Manage', manage_class)
      browser_class = Class.new do
        def self.manage
          Manage
        end
      end
      stub_const('Browser', browser_class)
      driver_class = Class.new do
        def self.browser
          Browser
        end
      end
      stub_const('Driver', driver_class)
    end

    let(:page) { double(Capybara.page) }

    it 'gets driver browser logs' do
      allow(page).to receive(:driver).and_return(Driver)

      expect(QA::Support::PageErrorChecker.logs(page)).to eq('logs at browser level')
    end
  end
end
