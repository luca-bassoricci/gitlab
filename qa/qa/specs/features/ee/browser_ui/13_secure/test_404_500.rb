# frozen_string_literal: true

module QA
  RSpec.describe 'Secure' do
    context 'TEst failures' do

      def admin_api_client
        @admin_api_client ||= Runtime::API::Client.as_admin
      end

      def owner_api_client
        @owner_api_client ||= Runtime::API::Client.new(:gitlab, user: owner_user)
      end

      let(:owner_user) do
        Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
      end

      let(:developer_user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      let(:sandbox_group) do
        Resource::Sandbox.fabricate! do |sandbox_group|
          sandbox_group.path = "test-sandbox-#{SecureRandom.hex(4)}"
          sandbox_group.api_client = owner_api_client
        end
      end

      let(:group) do
        QA::Resource::Group.fabricate_via_api! do |group|
          group.sandbox = sandbox_group
          group.api_client = owner_api_client
        end
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-secure'
          project.description = 'Project with Secure'
          project.group = group
        end
      end

      before do
        Flow::Login.sign_in_unless_signed_in
        group.add_member(developer_user, Resource::Members::AccessLevel::DEVELOPER)
      end

      after do
        project.remove_via_api!
      end

      describe 'Failure', :aggregate_failures do



        it 'fails to visit project with 404' do
          Flow::Login.sign_in(as: developer_user, skip_page_validation: true)
          project.visit!
          project.remove_via_api!
          # require 'pry'
          # binding.pry
          project.visit!
        end

        it 'fails due to 500' do
          Flow::Login.sign_in_unless_signed_in
          project.visit!

          Page::Project::Menu.perform(&:go_to_repository_settings)

          Page::Project::Settings::Repository.perform do |repository|
            repository.expand_push_rules do |push_rules|
              push_rules.fill_file_size('99999999999999999999')
              # require 'pry'
              # binding.pry
              push_rules.click_submit
              expect(push_rules).not_to have_element(:create_tag_button)
            end
          end
        end
      end
    end
  end
end
