# frozen_string_literal: true

module Gitlab
  module Diff
    class HighlightedLines
      def initialize(diff_file)
        @diff_file = diff_file
        @chunks = []
        @mapper = {}

        calculate!
      end

      def for(diff_line)
        return if mapper.blank?

        chunk_index, line_index = mapper[diff_line.line_code]
        lines = chunks[chunk_index]
        lines && lines[line_index]&.html_safe
      end

      private

      attr_reader :diff_file, :chunks, :mapper

      # The idea is to extract new and old versions of the blob from the diff content.
      # For example, when there is:
      #
      # ```
      # @@ -96,12 +96,6 @@ end
      #
      # - def main
      # -  'hello'
      # - end
      #
      #   def other
      #     'other'
      # @@ -200007,6 +200001,12 @@ end
      #
      # + def main
      # +  'hello'
      # + end
      #
      #   def another
      #     'another'
      # ```
      #
      # We want to separate it into old chunks:
      #
      # [["def main", "  hello", "end"], []]
      #
      # And new chunks:
      #
      # [["end", "", "", "def other", "  'other'"], ["end", "", "", "def another", "  'another'"]]
      #
      # Then highlight each chunk separately and then map it to the diff lines
      def calculate!
        return unless diff_file && diff_file.diff_refs

        new_lines, old_lines = [], []

        diff_file.diff_lines.each do |diff_line|
          # Remove line prefix (+ or -) from the beginning of the line
          text = diff_line.text[1..-1].to_s

          if diff_line.unchanged? || diff_line.added?
            mapper[diff_line.line_code] = [chunks.size, new_lines.size]

            new_lines << text
          end

          if diff_line.removed?
            mapper[diff_line.line_code] = [chunks.size + 1, old_lines.size]

            old_lines << text
          end

          if diff_line.meta?
            chunks << highlighted(diff_file.new_path, new_lines)
            chunks << highlighted(diff_file.old_path, old_lines)

            new_lines, old_lines = [], []
          end
        end

        chunks << highlighted(diff_file.new_path, new_lines)
        chunks << highlighted(diff_file.old_path, old_lines)
      end

      def highlighted(path, lines)
        Gitlab::Highlight.highlight(path, lines.join("\n"), plain: true).lines
      end
    end
  end
end
