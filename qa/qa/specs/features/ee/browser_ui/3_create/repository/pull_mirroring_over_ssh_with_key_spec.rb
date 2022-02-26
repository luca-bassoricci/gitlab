# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Pull mirror a repository over SSH with a private key' do
      let(:source) do
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project_name = 'pull-mirror-source-project'
          project_push.file_name = 'README.md'
          project_push.file_content = '# This is a pull mirroring test project'
          project_push.commit_message = 'Add README.md'
        end
      end

      let(:source_project_uri) { source.project.repository_ssh_location.uri }
      let(:target_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'pull-mirror-target-project'
        end
      end

      before do
        Flow::Login.sign_in

        target_project.visit!
      end

      it 'configures and syncs a (pull) mirrored repository', quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/352197', type: :investigating }, :aggregate_failures,
        testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/347736',
        quarantine: {
          only: { subdomain: :staging },
          type: :test_environment,
          issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/352706'
        } do
        # Configure the target project to pull from the source project
        # And get the public key to be used as a deploy key
        Page::Project::Menu.perform(&:go_to_repository_settings)
        public_key = Page::Project::Settings::Repository.perform do |settings|
          settings.expand_mirroring_repositories do |mirror_settings|
            mirror_settings.repository_url = source_project_uri
            mirror_settings.mirror_direction = 'Pull'
            mirror_settings.authentication_method = 'SSH public key'
            mirror_settings.detect_host_keys
            mirror_settings.mirror_repository
            mirror_settings.public_key source_project_uri
          end
        end

        # Add the public key to the source project as a deploy key
        Resource::DeployKey.fabricate_via_api! do |deploy_key|
          deploy_key.project = source.project
          deploy_key.title = "pull mirror key #{Time.now.to_f}"
          deploy_key.key = public_key
        end

        # Sync the repositories
        target_project.visit!
        Page::Project::Menu.perform(&:go_to_repository_settings)
        Page::Project::Settings::Repository.perform do |settings|
          settings.expand_mirroring_repositories do |mirror_settings|
            mirror_settings.update(source_project_uri) # rubocop:disable Rails/SaveBang

            # Use the API to wait until the update was successful (pull mirroring is treated as an import)
            mirror_succeeded = mirror_settings.wait_until(reload: false, max_duration: 180, sleep_interval: 1, raise_on_failure: false) do
              target_project.reload!
              target_project.api_resource[:import_status] == "finished"
            end

            unless mirror_succeeded
              raise "Mirroring failed with error: #{target_project.api_resource[:import_error]}"
            end

            mirror_settings.verify_update(source_project_uri)
          end
        end

        # Check that the target project has the commit from the source
        target_project.visit!
        Page::Project::Show.perform do |project|
          expect { project.has_file?('README.md') }.to eventually_be_truthy.within(max_duration: 60), "Expected a file named README.md but it did not appear."
          expect(project).to have_readme_content('This is a pull mirroring test project')
          expect(project).to have_text("Mirrored from #{masked_url(source_project_uri)}")
        end
      end

      def masked_url(url)
        url.user = '*****'
        url
      end
    end
  end
end
