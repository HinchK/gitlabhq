<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  inject: ['canUpdate'],
  props: {
    formattedDate: {
      required: true,
      type: String,
    },
    hasDate: {
      required: true,
      type: Boolean,
    },
    resetText: {
      required: true,
      type: String,
    },
    isLoading: {
      required: true,
      type: Boolean,
    },
    canDelete: {
      required: false,
      type: Boolean,
      default: true,
    },
  },
};
</script>

<template>
  <div class="hide-collapsed gl-flex gl-items-center">
    <span
      :class="hasDate ? 'gl-text-gray-900' : 'gl-text-gray-500'"
      data-testid="sidebar-date-value"
    >
      {{ formattedDate }}
    </span>
    <div v-if="hasDate && canUpdate && canDelete" class="gl-flex">
      <span class="gl-px-2">-</span>
      <gl-button
        variant="link"
        class="!gl-text-gray-500"
        data-testid="reset-button"
        :disabled="isLoading"
        @click="$emit('reset-date', $event)"
      >
        {{ resetText }}
      </gl-button>
    </div>
  </div>
</template>
