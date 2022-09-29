# frozen_string_literal: true

module Banzai
  module Pipeline
    class AsciiDocPipeline < BasePipeline
      def self.filters
        FilterArray[
          Filter::AsciiDocSanitizationFilter,
          Filter::AssetProxyFilter,
          Filter::ExternalLinkFilter,
          Filter::PlantumlFilter,
          Filter::ColorFilter,
          Filter::ImageLazyLoadFilter,
          Filter::ImageLinkFilter,
          Filter::AsciiDocPostProcessingFilter,
          Filter::SyntaxHighlightFilter
        ]
      end

      def self.transform_context(context)
        Filter::AssetProxyFilter.transform_context(context)
      end
    end
  end
end
