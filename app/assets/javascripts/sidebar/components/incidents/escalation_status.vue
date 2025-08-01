<script>
import { GlCollapsibleListbox } from '@gitlab/ui';
import {
  INCIDENTS_I18N as i18n,
  STATUS_ACKNOWLEDGED,
  STATUS_TRIGGERED,
  STATUS_RESOLVED,
} from '../../constants';
import { getStatusLabel } from '../../utils';

const STATUS_LIST = [STATUS_TRIGGERED, STATUS_ACKNOWLEDGED, STATUS_RESOLVED];

export default {
  i18n,
  STATUS_LIST,
  components: {
    GlCollapsibleListbox,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: null,
      validator(value) {
        return [...STATUS_LIST, null].includes(value);
      },
    },
    headerText: {
      type: String,
      required: false,
      default: null,
    },
    statusSubtexts: {
      type: Object,
      required: false,
      default() {
        return {};
      },
    },
  },
  computed: {
    statusDropdownOptions() {
      return this.$options.STATUS_LIST.map((status) => ({
        text: this.getStatusLabel(status),
        subtext: this.statusSubtexts[status],
        value: status,
      }));
    },
    currentStatusLabel() {
      return this.getStatusLabel(this.value);
    },
  },

  methods: {
    // eslint-disable-next-line vue/no-unused-properties -- show() is part of the component's public API
    show() {
      this.$refs.dropdown.open();
    },
    // eslint-disable-next-line vue/no-unused-properties -- hide() is part of the component's public API
    hide() {
      this.$refs.dropdown.close();
    },
    getStatusLabel,
  },
};
</script>

<template>
  <gl-collapsible-listbox
    ref="dropdown"
    :selected="value"
    :header-text="headerText"
    block
    :toggle-text="currentStatusLabel"
    :items="statusDropdownOptions"
    toggle-class="dropdown-menu-toggle gl-mb-2"
    data-testid="escalation-status-dropdown"
    @select="$emit('input', $event)"
  >
    <template #list-item="{ item }">
      <span class="gl-block">{{ item.text }}</span>
      <span v-if="item.subtext" class="gl-text-sm gl-text-subtle">{{ item.subtext }}</span>
    </template>
  </gl-collapsible-listbox>
</template>
