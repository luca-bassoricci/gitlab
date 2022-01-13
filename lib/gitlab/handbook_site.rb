# frozen_string_literal: true

module Gitlab
  module HandbookSite
    class << self
      def self.default_base_url
        "#{::Gitlab::MarketingSite.base_url}/handbook"
      end

      def self.base_url
        ENV.fetch('HANDBOOK_SITE_URL', default_base_url)
      end

      PATHS_MAP = {
        security: 'security'
      }.freeze

      KNOWN_PATHS = PATHS_MAP.keys.freeze

      def self.security_url(target: nil)
        fragment = target ? "##{target}" : nil

        "#{base_url}/security/#{fragment}"
      end
    end
  end
end
