module QA
  module EE
    module Page
      module Project
        module Settings
          module ProtectedBranches
            def self.prepended(page)
              page.module_eval do
                view 'ee/app/views/projects/protected_branches/_protected_branch_access_summary.html.haml' do
                  element :allowed_to_merge
                end
              end
            end
          end
        end
      end
    end
  end
end
