# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Repository Usage Quota for Pooled Repos', :skip_live_env,
             feature_flag: { name: 'gitaly_revlist_for_repo_size', scope: :global } do
      flag_enabled ||= Runtime::Feature.enabled?(:gitaly_revlist_for_repo_size)

      let(:praefect_manager) { Service::PraefectManager.new }
      let(:data50kb) { SecureRandom.hex(50_000) }
      let(:data40kb) { SecureRandom.hex(40_000) }
      let(:data30kb) { SecureRandom.hex(30_000) }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = "gitaly_cluster-repository-usage-#{SecureRandom.hex(4)}"
        end
      end

      before do
        Runtime::Feature.enable(:gitaly_revlist_for_repo_size)
      end

      after do
        Runtime::Feature.set({ gitaly_revlist_for_repo_size: flag_enabled })
        praefect_manager.reconfigure_gitaly_nodes
      end

      context 'when git does not have customised core.alternaterefscommand configuration' do
        before do
          praefect_manager.omnibus_config_disable_alternate_refs
        end

        it "calculates the repo size excluding pooled data",
           testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/TODO' do
          # Add a 50kb file
          commit_file_to_project(project, 'data50kb.txt', data50kb)

          # See https://docs.gitlab.com/ee/administration/repository_storage_types.html#hashed-object-pools
          fork = Resource::Fork.fabricate_via_api! do |fork|
            fork.upstream = project
            fork.name = "gitaly_cluster-repository-usage-#{SecureRandom.hex(4)}-fork"
          end

          # Add some unique data to both projects
          commit_file_to_project(fork.project, 'data40kb.txt', data40kb)
          commit_file_to_project(project, 'data30kb.txt', data30kb)

          praefect_manager.wait_for_empty_replication_queue
          # See https://docs.gitlab.com/ee/administration/housekeeping.html#how-housekeeping-handles-pool-repositories
          perform_housekeeping(project, fork, 0)

          # Leeway provided for data compression
          expect(project.statistics[:repository_size].to_i).to eq(0)
          expect(fork.project.statistics[:repository_size].to_i).to be_within(40_000 * 0.25).of(40_000)
        end
      end

      context 'when git has a customised core.alternaterefscommand configuration' do
        before do
          # Omnibus is configured with a configuration `core.alternateRefsCommand "exit 0 #"`
          # https://git-scm.com/docs/git-config/2.37.1#Documentation/git-config.txt-corealternateRefsCommand
          praefect_manager.omnibus_config_enable_alternate_refs
        end
        it "calculates the repo size including pooled data",
           testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/TODO' do
          # Add a 50kb file
          commit_file_to_project(project, 'data50kb.txt', data50kb)

          # See https://docs.gitlab.com/ee/administration/repository_storage_types.html#hashed-object-pools
          fork = Resource::Fork.fabricate_via_api! do |fork|
            fork.upstream = project
            fork.name = "repository-usage-#{SecureRandom.hex(4)}-fork"
          end

          # Add some unique data to both projects
          commit_file_to_project(fork.project, 'data40kb.txt', data40kb)
          commit_file_to_project(project, 'data30kb.txt', data30kb)

          praefect_manager.wait_for_empty_replication_queue
          # See https://docs.gitlab.com/ee/administration/housekeeping.html#how-housekeeping-handles-pool-repositories
          perform_housekeeping(project, fork)

          # Leeway provided for data compression
          expect(project.statistics[:repository_size].to_i).to be_within(80_000 * 0.25).of(80_000)
          expect(fork.project.statistics[:repository_size].to_i).to be_within(90_000 * 0.25).of(90_000)
        end
      end

      private

      def commit_file_to_project(project, file_name, data)
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.add_files([{ file_path: file_name, content: data }])
        end
      end

      def perform_housekeeping(project, fork, target_size = nil)
        initial_size = project.reload!.statistics[:repository_size].to_i
        # See https://docs.gitlab.com/ee/administration/housekeeping.html#how-housekeeping-handles-pool-repositories
        project.perform_housekeeping
        fork.project.perform_housekeeping
        # This runs async so we need to allow some time for the housekeeping to complete
        Support::Retrier.retry_until(max_duration: 60, sleep_interval: 1) do
          fork.project.calculate_repository_size
          project.calculate_repository_size

          project_size = project.statistics[:repository_size].to_i
          fork_size = fork.project.statistics[:repository_size].to_i

          QA::Runtime::Logger.info(%Q[#{self.class.name} - initial_size #{initial_size}
            project_size #{project_size} - fork_size #{fork_size}])

          if target_size == 0
            project_size == 0
          else
            project_size != initial_size
          end
        end
      end
    end
  end
end
