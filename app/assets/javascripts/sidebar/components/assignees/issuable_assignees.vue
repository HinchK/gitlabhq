<script>
import { GlButton } from '@gitlab/ui';
import { TYPE_ISSUE } from '~/issues/constants';
import UncollapsedAssigneeList from './uncollapsed_assignee_list.vue';

export default {
  components: {
    GlButton,
    UncollapsedAssigneeList,
  },
  props: {
    users: {
      type: Array,
      required: true,
    },
    issuableType: {
      type: String,
      required: false,
      default: TYPE_ISSUE,
    },
    signedIn: {
      type: Boolean,
      required: false,
      default: false,
    },
    editable: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    emptyUsers() {
      return this.users.length === 0;
    },
  },
};
</script>

<template>
  <div class="issuable-assignees gl-flex gl-flex-col">
    <div
      v-if="emptyUsers"
      class="hide-collapsed gl-flex gl-items-center gl-text-subtle"
      data-testid="none"
    >
      <span> {{ __('None') }}</span>
      <template v-if="signedIn && editable">
        <span class="gl-ml-2">-</span>
        <gl-button
          data-testid="assign-yourself"
          class="gl-ml-2 !gl-text-inherit hover:!gl-text-link"
          variant="link"
          @click="$emit('assign-self')"
        >
          {{ __('assign yourself') }}
        </gl-button>
      </template>
    </div>
    <uncollapsed-assignee-list
      v-else
      :users="users"
      :issuable-type="issuableType"
      class="hide-collapsed gl-pt-2"
    />
  </div>
</template>
