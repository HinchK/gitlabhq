# frozen_string_literal: true

class FinalizeBackfillPackagesHelmFileMetadataProjectId < Gitlab::Database::Migration[2.3]
  milestone '18.2'
  disable_ddl_transaction!

  restrict_gitlab_migration gitlab_schema: :gitlab_main_cell

  def up
    ensure_batched_background_migration_is_finished(
      job_class_name: 'BackfillPackagesHelmFileMetadataProjectId',
      table_name: :packages_helm_file_metadata,
      column_name: :package_file_id,
      job_arguments: [:project_id, :packages_package_files, :project_id, :package_file_id],
      finalize: true
    )
  end

  def down; end
end
