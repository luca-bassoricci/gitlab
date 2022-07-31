# frozen_string_literal: true

module Gitlab
  module MimeHelper
    def guess_content_type(filename)
      types = MIME::Types.type_for(filename)

      if types.present?
        types.first.content_type
      else
        "application/octet-stream"
      end
    end
  end
end
