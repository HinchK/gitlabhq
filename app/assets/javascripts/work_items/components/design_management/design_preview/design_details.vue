<!-- eslint-disable vue/multi-word-component-names -->
<script>
import { GlAlert } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { fetchPolicies } from '~/lib/graphql';
import { Mousetrap } from '~/lib/mousetrap';
import { keysFor, ISSUE_CLOSE_DESIGN } from '~/behaviors/shortcuts/keybindings';
import { ROUTES } from '../../../constants';
import getDesignQuery from '../graphql/design_details.query.graphql';
import getLocalDesignQuery from '../graphql/local_design.query.graphql';
import { extractDesign, extractDiscussions, getPageLayoutElement } from '../utils';
import { updateWorkItemDesignCurrentTodosWidget } from '../cache_updates';
import {
  DESIGN_DETAIL_LAYOUT_CLASSLIST,
  DESIGN_NOT_FOUND_ERROR,
  DESIGN_VERSION_NOT_EXIST_ERROR,
} from '../constants';
import DesignPresentation from './design_presentation.vue';
import DesignToolbar from './design_toolbar.vue';
import DesignSidebar from './design_sidebar.vue';
import DesignScaler from './design_scaler.vue';

const DEFAULT_SCALE = 1;
const DEFAULT_MAX_SCALE = 2;

export default {
  components: {
    DesignPresentation,
    DesignSidebar,
    DesignToolbar,
    DesignScaler,
    GlAlert,
  },
  inject: ['fullPath'],
  beforeRouteUpdate(to, from, next) {
    // reset scale when the active design changes
    this.scale = DEFAULT_SCALE;
    next();
  },
  beforeRouteEnter(to, from, next) {
    const pageEl = getPageLayoutElement();
    if (pageEl) {
      pageEl.classList.add(...DESIGN_DETAIL_LAYOUT_CLASSLIST);
    }

    next();
  },
  beforeRouteLeave(to, from, next) {
    const pageEl = getPageLayoutElement();
    if (pageEl) {
      pageEl.classList.remove(...DESIGN_DETAIL_LAYOUT_CLASSLIST);
    }

    next();
  },
  props: {
    iid: {
      type: String,
      required: true,
    },
    allDesigns: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      designSource: {},
      localDesign: {},
      annotationCoordinates: null,
      errorMessage: '',
      scale: DEFAULT_SCALE,
      resolvedDiscussionsExpanded: false,
      prevCurrentUserTodos: null,
      maxScale: DEFAULT_MAX_SCALE,
      workItemId: '',
      workItemTitle: '',
      isSidebarOpen: true,
    };
  },
  apollo: {
    // If a design is opened and closed, the design is cached by Apollo.
    // But it will replace the design widget cache of the design list query.
    // So, while writing the designSource cache, Apollo is not able to find the existing cache
    // and throws error while writing the cache. This is a known issue.
    // As a workaround, the local design will help in maintaining the design cache.
    // https://gitlab.com/gitlab-org/gitlab/-/issues/461539
    localDesign: {
      query: getLocalDesignQuery,
      variables() {
        return {
          filenames: [this.$route.params.id],
          atVersion: this.designsVersion,
        };
      },
    },
    designSource: {
      query: getDesignQuery,
      fetchPolicy: fetchPolicies.NO_CACHE,
      notifyOnNetworkStatusChange: true,
      variables() {
        return this.designVariables;
      },
      update: (data) => data,
      result(res) {
        this.onDesignQueryResult(res);
      },
      error() {
        this.onQueryError(DESIGN_NOT_FOUND_ERROR);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.loading && !this.design.id;
    },
    design() {
      return this.localDesign || {};
    },
    designVariables() {
      return {
        fullPath: this.fullPath,
        iid: this.iid,
        filenames: [this.$route.params.id],
        atVersion: this.designsVersion,
      };
    },
    hasValidVersion() {
      return this.$route.query.version;
    },
    designsVersion() {
      return this.hasValidVersion
        ? `gid://gitlab/DesignManagement::Version/${this.$route.query.version}`
        : null;
    },
    discussions() {
      if (!this.design.discussions) {
        return [];
      }
      return extractDiscussions(this.design.discussions);
    },
    resolvedDiscussions() {
      return this.discussions.filter((discussion) => discussion.resolved);
    },
    currentUserDesignTodos() {
      return this.design?.currentUserTodos?.nodes;
    },
  },
  watch: {
    resolvedDiscussions(val) {
      if (!val.length) {
        this.resolvedDiscussionsExpanded = false;
      }
    },
  },
  mounted() {
    Mousetrap.bind(keysFor(ISSUE_CLOSE_DESIGN), this.closeDesign);
  },
  methods: {
    onDesignQueryResult({ data, loading }) {
      // On the initial load with cache-and-network policy data is undefined while loading is true
      // To prevent throwing an error, we don't perform any logic until loading is false
      if (loading) {
        return;
      }

      if (!data || !extractDesign(data)) {
        this.onQueryError(DESIGN_NOT_FOUND_ERROR);
      } else if (this.$route.query.version && !this.hasValidVersion) {
        this.onQueryError(DESIGN_VERSION_NOT_EXIST_ERROR);
      } else {
        const workItem = data.project.workItems.nodes[0];
        this.workItemId = workItem.id;
        this.workItemTitle = workItem.title;

        // Write to the localDesign cache which is separate from designSource when design is opened.
        this.$apollo.provider.defaultClient.cache.writeQuery({
          query: getLocalDesignQuery,
          variables: {
            filenames: [this.$route.params.id],
            atVersion: this.designsVersion,
          },
          data: {
            localDesign: extractDesign(data),
          },
        });
      }
    },
    onQueryError(message) {
      // because we redirect user to work item page,
      // we want to create these alerts on the work item page
      createAlert({ message });
      this.$router.push({ name: ROUTES.workItem });
    },
    onError(message, e) {
      this.errorMessage = message;
      if (e) throw e;
    },
    closeDesign() {
      this.$router.push({
        name: ROUTES.workItem,
        query: this.$route.query,
      });
    },
    setMaxScale(event) {
      this.maxScale = 1 / event;
    },
    toggleSidebar() {
      this.isSidebarOpen = !this.isSidebarOpen;
    },
    toggleResolvedComments(newValue) {
      this.resolvedDiscussionsExpanded = newValue;
    },
    updateWorkItemDesignCurrentTodosWidgetCache({ cache, todos }) {
      // Write the updated todos to the localDesign cache instead of designSource
      // to maintain it even if a new design is opened.
      updateWorkItemDesignCurrentTodosWidget({
        store: cache,
        todos,
        query: {
          query: getLocalDesignQuery,
          variables: {
            filenames: [this.$route.params.id],
            atVersion: this.designsVersion,
          },
        },
      });
    },
  },
};
</script>

<template>
  <div
    class="design-detail js-design-detail fixed-top gl-flex gl-w-full gl-flex-col gl-justify-center gl-bg-gray-10 lg:gl-flex-row"
  >
    <div class="gl-relative gl-flex gl-grow gl-flex-col gl-overflow-hidden">
      <design-toolbar
        :work-item-title="workItemTitle"
        :design="design"
        :design-filename="$route.params.id"
        :is-loading="isLoading"
        :is-sidebar-open="isSidebarOpen"
        :all-designs="allDesigns"
        :current-user-design-todos="currentUserDesignTodos"
        @toggle-sidebar="toggleSidebar"
        @todosUpdated="updateWorkItemDesignCurrentTodosWidgetCache"
      />
      <div class="gl-relative gl-flex gl-grow gl-flex-col gl-overflow-hidden lg:gl-flex-row">
        <div class="gl-relative gl-flex gl-grow-2 gl-flex-col gl-overflow-hidden">
          <div v-if="errorMessage" class="gl-p-5">
            <gl-alert variant="danger" @dismiss="errorMessage = null">
              {{ errorMessage }}
            </gl-alert>
          </div>
          <design-presentation
            :image="design.image"
            :image-name="design.filename"
            :discussions="discussions"
            :scale="scale"
            :resolved-discussions-expanded="resolvedDiscussionsExpanded"
            :is-loading="isLoading"
            disable-commenting
            @setMaxScale="setMaxScale"
          />
        </div>
        <div
          class="design-scaler-wrapper gl-absolute gl-mb-6 gl-flex gl-items-center gl-justify-center"
        >
          <design-scaler :max-scale="maxScale" @scale="scale = $event" />
        </div>
        <design-sidebar
          :design="design"
          :is-loading="isLoading"
          :is-open="isSidebarOpen"
          :resolved-discussions-expanded="resolvedDiscussionsExpanded"
          @toggleResolvedComments="toggleResolvedComments"
        />
      </div>
    </div>
  </div>
</template>
