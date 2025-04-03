import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { DESIGN_MARK_APP_START, DESIGN_MEASURE_BEFORE_APP } from '~/performance/constants';
import { performanceMarkAndMeasure } from '~/performance/utils';
import { WORKSPACE_GROUP } from '~/issues/constants';
import { addShortcutsExtension } from '~/behaviors/shortcuts';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import { parseBoolean } from '~/lib/utils/common_utils';
import { injectVueAppBreadcrumbs } from '~/lib/utils/breadcrumbs';
import { apolloProvider } from '~/graphql_shared/issuable_client';
import { __ } from '~/locale';
import { NEW_ISSUE_FEEDBACK_PROMPT_EXPIRY } from '~/work_items/constants';
import App from './components/app.vue';
import WorkItemBreadcrumb from './components/work_item_breadcrumb.vue';
import activeDiscussionQuery from './components/design_management/graphql/client/active_design_discussion.query.graphql';
import { createRouter } from './router';

Vue.use(VueApollo);

export const initWorkItemsRoot = ({ workItemType, workspaceType, withTabs } = {}) => {
  const el = document.querySelector('#js-work-items');

  if (!el) {
    return undefined;
  }

  addShortcutsExtension(ShortcutsNavigation);

  const {
    canAdminLabel,
    fullPath,
    groupPath,
    groupId,
    hasIssueWeightsFeature,
    issuesListPath,
    epicsListPath,
    labelsManagePath,
    registerPath,
    signInPath,
    hasIterationsFeature,
    hasOkrsFeature,
    hasSubepicsFeature,
    hasIssuableHealthStatusFeature,
    newCommentTemplatePaths,
    reportAbusePath,
    defaultBranch,
    initialSort,
    isSignedIn,
    workItemType: listWorkItemType,
    hasEpicsFeature,
    showNewIssueLink,
    canCreateEpic,
    autocompleteAwardEmojisPath,
    hasScopedLabelsFeature,
    hasQualityManagementFeature,
    canBulkEditEpics,
    groupIssuesPath,
    labelsFetchPath,
    hasLinkedItemsEpicsFeature,
    canCreateProjects,
    newProjectPath,
    hasIssueDateFilterFeature,
    timeTrackingLimitToHours,
  } = el.dataset;

  const isGroup = workspaceType === WORKSPACE_GROUP;
  const router = createRouter({ fullPath, workItemType, workspaceType, defaultBranch, isGroup });
  let listPath = issuesListPath;

  const breadcrumbParams = { workItemType: listWorkItemType, isGroup };

  if (isGroup) {
    listPath = epicsListPath;
    breadcrumbParams.listPath = epicsListPath;
  } else {
    breadcrumbParams.listPath = issuesListPath;
  }

  injectVueAppBreadcrumbs(router, WorkItemBreadcrumb, apolloProvider, breadcrumbParams);

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: activeDiscussionQuery,
    data: {
      activeDesignDiscussion: {
        __typename: 'ActiveDesignDiscussion',
        id: null,
        source: null,
      },
    },
  });

  const feedback = {};

  if (gon.features.workItemViewForIssues) {
    feedback.feedbackIssue = 'https://gitlab.com/gitlab-org/gitlab/-/issues/523713';
    feedback.feedbackIssueText = __('Provide feedback on the experience');
    feedback.content = __(
      'We’ve introduced some improvements to the issue page such as real time updates, additional features, and a refreshed design. Have questions or thoughts on the changes?',
    );
    feedback.title = __('New issue look');
    feedback.featureName = 'work_item_epic_feedback';
    feedback.expiry = NEW_ISSUE_FEEDBACK_PROMPT_EXPIRY;
  }

  if (
    workItemType === 'issue' &&
    gon.features.workItemsViewPreference &&
    !isGroup &&
    !gon.features.useWiViewForIssues
  ) {
    import(/* webpackChunkName: 'work_items_feedback' */ '~/work_items_feedback')
      .then(({ initWorkItemsFeedback }) => {
        initWorkItemsFeedback(feedback);
      })
      .catch({});
  }

  return new Vue({
    el,
    name: 'WorkItemsRoot',
    router,
    apolloProvider,
    provide: {
      canAdminLabel,
      fullPath,
      isGroup,
      isProject: !isGroup,
      hasIssueWeightsFeature: parseBoolean(hasIssueWeightsFeature),
      hasOkrsFeature: parseBoolean(hasOkrsFeature),
      hasSubepicsFeature: parseBoolean(hasSubepicsFeature),
      hasScopedLabelsFeature: parseBoolean(hasScopedLabelsFeature),
      issuesListPath: listPath,
      labelsManagePath,
      registerPath,
      signInPath,
      hasIterationsFeature: parseBoolean(hasIterationsFeature),
      hasIssuableHealthStatusFeature: parseBoolean(hasIssuableHealthStatusFeature),
      reportAbusePath,
      groupPath,
      groupId,
      initialSort,
      isSignedIn: parseBoolean(isSignedIn),
      workItemType: listWorkItemType,
      hasEpicsFeature: parseBoolean(hasEpicsFeature),
      showNewIssueLink: parseBoolean(showNewIssueLink),
      canCreateEpic: parseBoolean(canCreateEpic),
      autocompleteAwardEmojisPath,
      hasQualityManagementFeature: parseBoolean(hasQualityManagementFeature),
      canBulkEditEpics: parseBoolean(canBulkEditEpics),
      groupIssuesPath,
      labelsFetchPath,
      hasLinkedItemsEpicsFeature: parseBoolean(hasLinkedItemsEpicsFeature),
      canCreateProjects: parseBoolean(canCreateProjects),
      newIssuePath: '',
      newProjectPath,
      hasIssueDateFilterFeature: parseBoolean(hasIssueDateFilterFeature),
      timeTrackingLimitToHours: parseBoolean(timeTrackingLimitToHours),
    },
    mounted() {
      performanceMarkAndMeasure({
        mark: DESIGN_MARK_APP_START,
        measures: [
          {
            name: DESIGN_MEASURE_BEFORE_APP,
          },
        ],
      });
    },
    render(createElement) {
      return createElement(App, {
        props: {
          newCommentTemplatePaths: JSON.parse(newCommentTemplatePaths),
          withTabs,
        },
      });
    },
  });
};
