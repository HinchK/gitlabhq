<script>
import { mapState } from 'pinia';
import SafeHtml from '~/vue_shared/directives/safe_html';
import { __, sprintf } from '~/locale';
import { useNotes } from '~/notes/store/legacy_notes';

export default {
  directives: {
    SafeHtml,
  },
  computed: {
    ...mapState(useNotes, ['getNotesDataByProp']),
    registerLink() {
      return this.getNotesDataByProp('registerPath');
    },
    signInLink() {
      return this.getNotesDataByProp('newSessionPath');
    },
    signedOutText() {
      return sprintf(
        __(
          'Please %{startTagRegister}register%{endRegisterTag} or %{startTagSignIn}sign in%{endSignInTag} to reply',
        ),
        {
          startTagRegister: `<a href="${this.registerLink}">`,
          startTagSignIn: `<a href="${this.signInLink}">`,
          endRegisterTag: '</a>',
          endSignInTag: '</a>',
        },
        false,
      );
    },
  },
};
</script>

<template>
  <div v-safe-html="signedOutText" class="gl-grow gl-text-center gl-text-subtle"></div>
</template>
