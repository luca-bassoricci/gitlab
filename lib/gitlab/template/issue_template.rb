# frozen_string_literal: true

module Gitlab
  module Template
    class IssueTemplate < BaseTemplate
      class << self
        def extension
          '.md'
        end

        def base_dir
          '.gitlab/issue_templates/'
        end

        def finder(project)
          Gitlab::Template::Finders::RepoTemplateFinder.new(project, self.base_dir, self.extension, self.categories)
        end

        def by_category(category, project = nil, empty_category_title: nil)
          super(category, project, empty_category_title: _('Project Templates'))
        end

        def can_read_template?(user, project)
          super && Ability.allowed?(user, :read_issue, project)
        end
      end
    end
  end
end
