# frozen_string_literal: true

module Projects
  # Service class for performing operations that should take place after a
  # project has been renamed.
  #
  # Example usage:
  #
  #     project = Project.find(42)
  #
  #     project.update(...)
  #
  #     Projects::AfterRenameService.new(project).execute
  class AfterRenameService
    prepend ::EE::Projects::AfterRenameService

    attr_reader :project, :full_path_before, :full_path_after, :path_before

    RenameFailedError = Class.new(StandardError)

    # @param [Project] project The Project of the repository to rename.
    def initialize(project)
      @project = project

      # The full path of the namespace + project, before the rename took place.
      @full_path_before = project.full_path_was

      # The full path of the namespace + project, after the rename took place.
      @full_path_after = project.build_full_path

      # The path of just the project, before the rename took place.
      @path_before = project.path_was
    end

    def execute
      first_ensure_no_registry_tags_are_present
      expire_caches_before_rename
      rename_or_migrate_repository!
      send_move_instructions
      execute_system_hooks
      update_repository_configuration
      rename_transferred_documents
      log_completion
    end

    def first_ensure_no_registry_tags_are_present
      return unless project.has_container_registry_tags?

      raise RenameFailedError.new(
        "Project #{full_path_before} cannot be renamed because images are " \
          "present in its container registry"
      )
    end

    def expire_caches_before_rename
      project.expire_caches_before_rename(full_path_before)
    end

    def rename_or_migrate_repository!
      success =
        if migrate_to_hashed_storage?
          ::Projects::HashedStorageMigrationService
            .new(project, full_path_before)
            .execute
        else
          project.storage.rename_repo
        end

      rename_failed! unless success
    end

    def send_move_instructions
      return unless send_move_instructions?

      project.send_move_instructions(full_path_before)
    end

    def execute_system_hooks
      project.old_path_with_namespace = full_path_before
      SystemHooksService.new.execute_hooks_for(project, :rename)
    end

    def update_repository_configuration
      project.reload_repository!
      project.write_repository_config
    end

    def rename_transferred_documents
      if rename_uploads?
        Gitlab::UploadsTransfer
          .new
          .rename_project(path_before, project_path, namespace_full_path)
      end

      Gitlab::PagesTransfer
        .new
        .rename_project(path_before, project_path, namespace_full_path)
    end

    def log_completion
      Gitlab::AppLogger.info(
        "Project #{project.id} has been renamed from " \
          "#{full_path_before} to #{full_path_after}"
      )
    end

    def migrate_to_hashed_storage?
      Gitlab::CurrentSettings.hashed_storage_enabled? &&
        project.storage_upgradable? &&
        Feature.disabled?(:skip_hashed_storage_upgrade)
    end

    def send_move_instructions?
      !project.import_started?
    end

    def rename_uploads?
      !project.hashed_storage?(:attachments)
    end

    def project_path
      project.path
    end

    def namespace_full_path
      project.namespace.full_path
    end

    def rename_failed!
      error = "Repository #{full_path_before} could not be renamed to #{full_path_after}"

      Gitlab::AppLogger.error(error)

      raise RenameFailedError.new(error)
    end
  end
end
