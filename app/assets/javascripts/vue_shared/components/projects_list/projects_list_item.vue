<script>
import { GlIcon, GlBadge, GlTooltip } from '@gitlab/ui';

import {
  renderDeleteSuccessToast,
  deleteParams,
} from '~/vue_shared/components/projects_list/utils';
import ProjectListItemActions from '~/vue_shared/components/projects_list/project_list_item_actions.vue';
import ProjectListItemInactiveBadge from '~/vue_shared/components/projects_list/project_list_item_inactive_badge.vue';
import { VISIBILITY_TYPE_ICON, PROJECT_VISIBILITY_TYPE } from '~/visibility_level/constants';
import { ACCESS_LEVEL_LABELS, ACCESS_LEVEL_NO_ACCESS_INTEGER } from '~/access_level/constants';
import { FEATURABLE_ENABLED } from '~/featurable/constants';
import { __, s__, n__, sprintf } from '~/locale';
import { numberToHumanSize, numberToMetricPrefix } from '~/lib/utils/number_utils';
import { ACTION_DELETE } from '~/vue_shared/components/list_actions/constants';
import DeleteModal from '~/projects/components/shared/delete_modal.vue';
import ProjectListItemDelayedDeletionModalFooter from '~/vue_shared/components/projects_list/project_list_item_delayed_deletion_modal_footer.vue';
import {
  TIMESTAMP_TYPES,
  TIMESTAMP_TYPE_CREATED_AT,
} from '~/vue_shared/components/resource_lists/constants';
import { deleteProject } from '~/rest_api';
import { createAlert } from '~/alert';
import CiIcon from '~/vue_shared/components/ci_icon/ci_icon.vue';
import ListItem from '~/vue_shared/components/resource_lists/list_item.vue';
import ListItemStat from '~/vue_shared/components/resource_lists/list_item_stat.vue';
import ListItemDescription from '~/vue_shared/components/resource_lists/list_item_description.vue';
import TopicBadges from '~/vue_shared/components/topic_badges.vue';

export default {
  i18n: {
    stars: __('Stars'),
    forks: __('Forks'),
    issues: __('Issues'),
    mergeRequests: __('Merge requests'),
    topics: __('Topics'),
    topicsPopoverTargetText: __('+ %{count} more'),
    moreTopics: __('More topics'),
    project: __('Project'),
    deleteErrorMessage: s__(
      'Projects|An error occurred deleting the project. Please refresh the page to try again.',
    ),
    ciCatalogBadge: s__('CiCatalog|CI/CD Catalog project'),
  },
  components: {
    GlIcon,
    GlBadge,
    GlTooltip,
    ListItem,
    ListItemStat,
    DeleteModal,
    ListItemDescription,
    ProjectListItemActions,
    ProjectListItemInactiveBadge,
    CiIcon,
    TopicBadges,
    ProjectListItemDelayedDeletionModalFooter,
  },
  props: {
    project: {
      type: Object,
      required: true,
    },
    showProjectIcon: {
      type: Boolean,
      required: false,
      default: false,
    },
    listItemClass: {
      type: [String, Array, Object],
      required: false,
      default: '',
    },
    timestampType: {
      type: String,
      required: false,
      default: TIMESTAMP_TYPE_CREATED_AT,
      validator(value) {
        return TIMESTAMP_TYPES.includes(value);
      },
    },
  },
  data() {
    return {
      isDeleteModalVisible: false,
      isDeleteLoading: false,
    };
  },
  computed: {
    visibility() {
      return this.project.visibility;
    },
    visibilityIcon() {
      return VISIBILITY_TYPE_ICON[this.visibility];
    },
    visibilityTooltip() {
      return PROJECT_VISIBILITY_TYPE[this.visibility];
    },
    visibilityTooltipTarget() {
      return this.$refs?.visibilityIcon?.$el;
    },
    accessLevel() {
      return this.project.accessLevel?.integerValue;
    },
    accessLevelLabel() {
      return ACCESS_LEVEL_LABELS[this.accessLevel];
    },
    shouldShowAccessLevel() {
      return this.accessLevel !== undefined && this.accessLevel !== ACCESS_LEVEL_NO_ACCESS_INTEGER;
    },
    storageSize() {
      if (!this.hasStatistics) return null;
      if (!this.project.statistics) return s__('StorageSize|Unknown');

      return numberToHumanSize(this.project.statistics.storageSize || 0, 1);
    },
    hasStatistics() {
      return Object.hasOwn(this.project, 'statistics');
    },
    starsHref() {
      return `${this.project.relativeWebUrl}/-/starrers`;
    },
    mergeRequestsHref() {
      return `${this.project.relativeWebUrl}/-/merge_requests`;
    },
    forksHref() {
      return `${this.project.relativeWebUrl}/-/forks`;
    },
    issuesHref() {
      return `${this.project.relativeWebUrl}/-/issues`;
    },
    isMergeRequestsEnabled() {
      return (
        this.project.mergeRequestsAccessLevel?.toLowerCase() === FEATURABLE_ENABLED &&
        this.project.openMergeRequestsCount !== undefined
      );
    },
    isForkingEnabled() {
      return (
        this.project.forkingAccessLevel?.toLowerCase() === FEATURABLE_ENABLED &&
        this.project.forksCount !== undefined
      );
    },
    isIssuesEnabled() {
      return (
        this.project.issuesAccessLevel?.toLowerCase() === FEATURABLE_ENABLED &&
        this.project.openIssuesCount !== undefined
      );
    },
    hasTopics() {
      return this.project.topics.length;
    },
    starCount() {
      return numberToMetricPrefix(this.project.starCount);
    },
    openMergeRequestsCount() {
      if (!this.isMergeRequestsEnabled) {
        return null;
      }

      return numberToMetricPrefix(this.project.openMergeRequestsCount);
    },
    forksCount() {
      if (!this.isForkingEnabled) {
        return null;
      }

      return numberToMetricPrefix(this.project.forksCount);
    },
    openIssuesCount() {
      if (!this.isIssuesEnabled) {
        return null;
      }

      return numberToMetricPrefix(this.project.openIssuesCount);
    },
    hasActions() {
      return this.project.availableActions?.length;
    },
    hasActionDelete() {
      return this.project.availableActions?.includes(ACTION_DELETE);
    },
    pipelineStatus() {
      return this.project.pipeline?.detailedStatus;
    },
    dataTestid() {
      return `projects-list-item-${this.project.id}`;
    },
    starA11yText() {
      return sprintf(
        n__(
          '%{project} has %{number} star',
          '%{project} has %{number} stars',
          this.project.starCount,
        ),
        { project: this.project.avatarLabel, number: this.starCount },
      );
    },
    forkA11yText() {
      return sprintf(
        n__(
          '%{project} has %{number} fork',
          '%{project} has %{number} forks',
          this.project.forksCount,
        ),
        { project: this.project.avatarLabel, number: this.forksCount },
      );
    },
    mrA11yText() {
      return sprintf(
        n__(
          '%{project} has %{number} open merge request',
          '%{project} has %{number} open merge requests',
          this.project.openMergeRequestsCount,
        ),
        { project: this.project.avatarLabel, number: this.openMergeRequestsCount },
      );
    },
    openIssueA11yText() {
      return sprintf(
        n__(
          '%{project} has %{number} open issue',
          '%{project} has %{number} open issues',
          this.project.openIssuesCount,
        ),
        { project: this.project.avatarLabel, number: this.openIssuesCount },
      );
    },
  },
  methods: {
    onActionDelete() {
      this.isDeleteModalVisible = true;
    },
    async onDeleteModalPrimary() {
      this.isDeleteLoading = true;

      try {
        await deleteProject(this.project.id, deleteParams(this.project));
        this.$emit('refetch');
        renderDeleteSuccessToast(this.project, this.$options.i18n.project);
      } catch (error) {
        createAlert({ message: this.$options.i18n.deleteErrorMessage, error, captureError: true });
      } finally {
        this.isDeleteLoading = false;
      }
    },
    onVisibilityTooltipShown() {
      this.$emit('hover-visibility', this.visibility);
    },
    onTopicClick() {
      this.$emit('click-topic');
    },
  },
};
</script>

<template>
  <list-item
    :resource="project"
    :show-icon="showProjectIcon"
    icon-name="project"
    :list-item-class="listItemClass"
    :timestamp-type="timestampType"
    :data-testid="dataTestid"
    content-testid="project-content"
    @click-avatar="$emit('click-avatar')"
  >
    <template #avatar-meta>
      <template v-if="visibility">
        <gl-icon ref="visibilityIcon" :name="visibilityIcon" variant="subtle" />
        <gl-tooltip :target="() => visibilityTooltipTarget" @shown="onVisibilityTooltipShown">{{
          visibilityTooltip
        }}</gl-tooltip>
      </template>
      <gl-badge
        v-if="project.isCatalogResource"
        icon="catalog-checkmark"
        variant="info"
        data-testid="ci-catalog-badge"
        :href="project.exploreCatalogPath"
        >{{ $options.i18n.ciCatalogBadge }}</gl-badge
      >
      <gl-badge v-if="shouldShowAccessLevel" class="gl-block" data-testid="user-access-role">{{
        accessLevelLabel
      }}</gl-badge>
    </template>

    <template #avatar-default>
      <list-item-description :resource="project" />
      <topic-badges
        v-if="hasTopics"
        :topics="project.topics"
        class="gl-mt-3"
        data-testid="project-topics"
        @click="onTopicClick"
      />
    </template>

    <template #stats>
      <ci-icon v-if="pipelineStatus" :status="pipelineStatus" />
      <project-list-item-inactive-badge :project="project" />
      <gl-badge v-if="hasStatistics" data-testid="storage-size">{{ storageSize }}</gl-badge>
      <list-item-stat
        :href="starsHref"
        :tooltip-text="$options.i18n.stars"
        :a11y-text="starA11yText"
        icon-name="star-o"
        :stat="starCount"
        data-testid="stars-btn"
        @hover="$emit('hover-stat', 'stars-count')"
        @click="$emit('click-stat', 'stars-count')"
      />
      <list-item-stat
        v-if="isForkingEnabled"
        :href="forksHref"
        :tooltip-text="$options.i18n.forks"
        :a11y-text="forkA11yText"
        icon-name="fork"
        :stat="forksCount"
        data-testid="forks-btn"
        @hover="$emit('hover-stat', 'forks-count')"
        @click="$emit('click-stat', 'forks-count')"
      />
      <list-item-stat
        v-if="isMergeRequestsEnabled"
        :href="mergeRequestsHref"
        :tooltip-text="$options.i18n.mergeRequests"
        :a11y-text="mrA11yText"
        icon-name="merge-request"
        :stat="openMergeRequestsCount"
        data-testid="mrs-btn"
        @hover="$emit('hover-stat', 'mrs-count')"
        @click="$emit('click-stat', 'mrs-count')"
      />
      <list-item-stat
        v-if="isIssuesEnabled"
        :href="issuesHref"
        :tooltip-text="$options.i18n.issues"
        :a11y-text="openIssueA11yText"
        icon-name="issues"
        :stat="openIssuesCount"
        data-testid="issues-btn"
        @hover="$emit('hover-stat', 'issues-count')"
        @click="$emit('click-stat', 'issues-count')"
      />
    </template>

    <template v-if="hasActions" #actions>
      <project-list-item-actions
        :project="project"
        @refetch="$emit('refetch')"
        @delete="onActionDelete"
      />
    </template>

    <template #footer>
      <delete-modal
        v-if="hasActionDelete"
        v-model="isDeleteModalVisible"
        :confirm-phrase="project.fullPath"
        :name-with-namespace="project.nameWithNamespace"
        :is-fork="project.isForked"
        :confirm-loading="isDeleteLoading"
        :merge-requests-count="openMergeRequestsCount"
        :issues-count="openIssuesCount"
        :forks-count="forksCount"
        :stars-count="starCount"
        @primary="onDeleteModalPrimary"
      >
        <template #modal-footer
          ><project-list-item-delayed-deletion-modal-footer :project="project"
        /></template>
      </delete-modal>
    </template>
  </list-item>
</template>
