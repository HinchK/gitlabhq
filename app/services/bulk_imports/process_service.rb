# frozen_string_literal: true

module BulkImports
  class ProcessService
    PERFORM_DELAY = 5.seconds
    DEFAULT_BATCH_SIZE = 5

    attr_reader :bulk_import

    def initialize(bulk_import)
      @bulk_import = bulk_import
    end

    def execute
      return unless bulk_import
      return if bulk_import.completed?
      return bulk_import.fail_op! if all_entities_failed?
      return bulk_import.finish! if all_entities_processed? && bulk_import.started?
      return re_enqueue if max_batch_size_exceeded? # Do not start more jobs if max allowed are already running

      process_bulk_import
      re_enqueue
    end

    private

    def process_bulk_import
      bulk_import.start! if bulk_import.created?

      created_entities.first(next_batch_size).each do |entity|
        create_tracker(entity)

        entity.start!

        BulkImports::ExportRequestWorker.perform_async(entity.id)
      end
    end

    def entities
      @entities ||= bulk_import.entities
    end

    def created_entities
      entities.with_status(:created)
    end

    def all_entities_processed?
      entities.all? { |entity| entity.finished? || entity.failed? }
    end

    def all_entities_failed?
      entities.all?(&:failed?)
    end

    # A new BulkImportWorker job is enqueued to either
    #   - Process the new BulkImports::Entity created during import (e.g. for the subgroups)
    #   - Or to mark the `bulk_import` as finished
    def re_enqueue
      BulkImportWorker.perform_in(PERFORM_DELAY, bulk_import.id)
    end

    def started_entities
      entities.with_status(:started)
    end

    def max_batch_size_exceeded?
      started_entities.count >= DEFAULT_BATCH_SIZE
    end

    def next_batch_size
      [DEFAULT_BATCH_SIZE - started_entities.count, 0].max
    end

    def create_tracker(entity)
      entity.class.transaction do
        entity.pipelines.each do |pipeline|
          status = skip_pipeline?(pipeline, entity) ? :skipped : :created

          entity.trackers.create!(
            stage: pipeline[:stage],
            pipeline_name: pipeline[:pipeline],
            status: BulkImports::Tracker.state_machine.states[status].value
          )
        end
      end
    end

    def skip_pipeline?(pipeline, entity)
      return false unless entity.source_version.valid?

      minimum_version, maximum_version = pipeline.values_at(:minimum_source_version, :maximum_source_version)

      if source_version_out_of_range?(minimum_version, maximum_version, entity.source_version.without_patch)
        log_skipped_pipeline(pipeline, entity, minimum_version, maximum_version)
        return true
      end

      false
    end

    def source_version_out_of_range?(minimum_version, maximum_version, non_patch_source_version)
      (minimum_version && non_patch_source_version < Gitlab::VersionInfo.parse(minimum_version)) ||
        (maximum_version && non_patch_source_version > Gitlab::VersionInfo.parse(maximum_version))
    end

    def log_skipped_pipeline(pipeline, entity, minimum_version, maximum_version)
      logger.info(
        message: 'Pipeline skipped as source instance version not compatible with pipeline',
        bulk_import_entity_id: entity.id,
        bulk_import_id: entity.bulk_import_id,
        bulk_import_entity_type: entity.source_type,
        source_full_path: entity.source_full_path,
        pipeline_class: pipeline[:pipeline],
        minimum_source_version: minimum_version,
        maximum_source_version: maximum_version,
        source_version: entity.source_version.to_s,
        importer: 'gitlab_migration'
      )
    end

    def logger
      @logger ||= Gitlab::Import::Logger.build
    end
  end
end
