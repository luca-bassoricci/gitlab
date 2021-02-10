# frozen_string_literal: true

module Gitlab
  module Diff
    class HighlightedLines
      attr_reader :diff_file, :diff_lines, :new_chunks, :old_chunks, :mapper

      def initialize(diff_file)
        @diff_file = diff_file
        @diff_lines = diff_file.diff_lines
        @new_chunks = []
        @old_chunks = []
        @mapper = {}

        calculate!
      end

      def for(diff_line, index)
        return if mapper.blank?

        chunk_type, chunk_index, line_index = mapper[index]

        lines =
          if chunk_type == :new
            new_chunks[chunk_index]
          elsif chunk_type == :old
            old_chunks[chunk_index]
          end

        return unless lines

        # Add prefix to make the output similar to the current Gitlab::Diff::Highlight logic
        # When/If the logic from this class is established and blobless_diff_highlighting FF is removed
        # We can remove these lines and fix the tests
        rich_line = lines[line_index]
        if rich_line
          line_prefix = diff_line.text =~ /\A(.)/ ? Regexp.last_match(1) : ' '
          "#{line_prefix}#{rich_line}".html_safe
        end
      end

      private

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

        diff_lines.each_with_index do |diff_line, index|
          # Remove line prefix (+ or -) from the beginning of the line
          text = diff_line.text[1..-1].to_s

          if diff_line.unchanged? || diff_line.added?
            mapper[index] = [:new, new_chunks.size, new_lines.size]

            new_lines << text
          end

          if diff_line.removed?
            mapper[index] = [:old, old_chunks.size, old_lines.size]

            old_lines << text
          end

          if diff_line.meta?
            new_chunks << highlighted(diff_file.new_path, new_lines, new_language)
            old_chunks << highlighted(diff_file.old_path, old_lines, old_language)

            new_lines, old_lines = [], []
          end
        end

        new_chunks << highlighted(diff_file.new_path, new_lines, new_language)
        old_chunks << highlighted(diff_file.old_path, old_lines, old_language)
      end

      def highlighted(path, lines, language)
        Gitlab::Highlight.highlight(path, lines.join("\n"), language: language).lines
      end

      def old_language
        @old_language ||= diff_file.repository.gitattribute(diff_file.old_path, 'gitlab-language')
      end

      def new_language
        @new_language ||= diff_file.repository.gitattribute(diff_file.new_path, 'gitlab-language')
      end
    end
  end
end
