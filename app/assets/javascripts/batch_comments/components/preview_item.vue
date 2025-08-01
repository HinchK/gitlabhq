<script>
import { GlSprintf, GlIcon, GlButton } from '@gitlab/ui';
import { mapState } from 'pinia';
import { IMAGE_DIFF_POSITION_TYPE } from '~/diffs/constants';
import { sprintf, __ } from '~/locale';
import {
  getStartLineNumber,
  getEndLineNumber,
  getLineClasses,
} from '~/notes/components/multiline_comment_utils';
import { useLegacyDiffs } from '~/diffs/stores/legacy_diffs';
import { useNotes } from '~/notes/store/legacy_notes';
import resolvedStatusMixin from '../mixins/resolved_status';

export default {
  components: {
    GlIcon,
    GlSprintf,
    GlButton,
  },
  mixins: [resolvedStatusMixin],
  props: {
    draft: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(useLegacyDiffs, ['getDiffFileByHash']),
    ...mapState(useNotes, ['getDiscussion']),
    iconName() {
      return this.isDiffDiscussion || this.draft.line_code ? 'doc-text' : 'comment';
    },
    discussion() {
      return this.getDiscussion(this.draft.discussion_id);
    },
    isDiffDiscussion() {
      return this.discussion && this.discussion.diff_discussion;
    },
    titleText() {
      const file = this.discussion ? this.discussion.diff_file : this.draft;

      if (file?.file_path) {
        return file.file_path;
      }

      if (this.discussion) {
        return sprintf(
          __("%{authorsName}'s thread"),
          {
            authorsName: this.discussion.notes.find((note) => !note.system).author.name,
          },
          false,
        );
      }

      return __('Your new comment');
    },
    linePosition() {
      if (this.position?.position_type === IMAGE_DIFF_POSITION_TYPE) {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        return `${this.position.x}x ${this.position.y}y`;
      }

      return this.position?.new_line || this.position?.old_line;
    },
    content() {
      const el = document.createElement('div');
      // eslint-disable-next-line no-unsanitized/property
      el.innerHTML = this.draft.note_html;

      return el.textContent;
    },
    showLinePosition() {
      return this.draft.file_hash || this.isDiffDiscussion;
    },
    position() {
      return this.draft.position || this.discussion.position;
    },
    startLineNumber() {
      if (this.position?.position_type === IMAGE_DIFF_POSITION_TYPE) {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        return `${this.position.x}x ${this.position.y}y`;
      }
      return getStartLineNumber(this.position?.line_range);
    },
    endLineNumber() {
      return getEndLineNumber(this.position?.line_range);
    },
  },
  methods: {
    getLineClasses(lineNumber) {
      return getLineClasses(lineNumber);
    },
  },
  showStaysResolved: false,
};
</script>

<template>
  <span>
    <gl-button
      variant="link"
      class="review-preview-item-header !gl-justify-start"
      data-testid="preview-item-header"
      @click="$emit('click', draft)"
    >
      <gl-icon class="flex-shrink-0" :name="iconName" /><span class="text-nowrap gl-items-center">
        <span class="review-preview-item-header-text gl-truncate">{{ titleText }}</span>
        <template v-if="showLinePosition">
          <template v-if="startLineNumber === endLineNumber">
            :<span :class="getLineClasses(startLineNumber)">{{ startLineNumber }}</span>
          </template>
          <gl-sprintf v-else :message="__(':%{startLine} to %{endLine}')">
            <template #startLine>
              <span class="gl-mr-2" :class="getLineClasses(startLineNumber)">{{
                startLineNumber
              }}</span>
            </template>
            <template #endLine>
              <span class="gl-ml-2" :class="getLineClasses(endLineNumber)">{{
                endLineNumber
              }}</span>
            </template>
          </gl-sprintf>
        </template>
      </span>
    </gl-button>
    <span class="review-preview-item-content">
      <p>{{ content }}</p>
    </span>
    <span
      v-if="draft.discussion_id && resolvedStatusMessage"
      class="review-preview-item-footer draft-note-resolution p-0"
    >
      <gl-icon class="gl-mr-3" name="status_success" /> {{ resolvedStatusMessage }}
    </span>
  </span>
</template>
