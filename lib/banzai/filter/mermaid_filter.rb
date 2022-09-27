# frozen_string_literal: true

# Generated HTML is transformed back to GFM by app/assets/javascripts/behaviors/markdown/nodes/code_block.js
module Banzai
  module Filter
    class MermaidFilter < HTML::Pipeline::Filter
      CSS   = 'pre[lang="mermaid"] > code'
      XPATH = Gitlab::Utils::Nokogiri.css_to_xpath(CSS).freeze

      def call
        doc.xpath(XPATH).each do |el|
          el.add_class('js-render-mermaid')
          el.parent['data-mermaid-style'] = 'display'
        end

        doc
      end
    end
  end
end
