# frozen_string_literal: true

module WorkItems
  module DataSync
    class BaseService < ::BaseContainerService
      include ::Services::ReturnServiceResponses

      attr_reader :work_item, :service_response, :target_namespace

      # work_item - original work item
      # target_namespace - ProjectNamespace, Group or Project
      # current_user - user performing the move/clone action
      def initialize(work_item:, target_namespace:, current_user: nil, params: {})
        # this helps reuse this service with Issue instances in legacy code, as well as WorkItem instances
        @work_item = ensure_work_item(work_item)
        @target_namespace = target_namespace

        super(container: work_item.namespace, current_user: current_user, params: params)
      end

      def execute(**args)
        @execution_arguments = args
        verification_response = verify_work_item_action_permission

        return verification_response if verification_response.error?

        data_sync_action
      end

      private

      def verify_work_item_action_permission!; end

      def data_sync_action; end

      def ensure_work_item(work_item)
        return work_item if work_item.is_a?(WorkItem)

        WorkItem.find_by_id(work_item) if work_item.is_a?(Issue)
      end
    end
  end
end
