# frozen_string_literal: true

class RaiseHeadersValueLimitsExternalDestinations < Gitlab::Database::Migration[2.2]
  milestone '18.0'

  disable_ddl_transaction!

  CONSTRAINT_NAME = 'check_ac213cca22'

  def up
    remove_check_constraint :audit_events_streaming_headers, CONSTRAINT_NAME
    add_check_constraint :audit_events_streaming_headers, 'char_length(value) <= 2000', CONSTRAINT_NAME
  end

  def down
    # noop: In case there are values over 255 (previous vlaue)
  end
end
