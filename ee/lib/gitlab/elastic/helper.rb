# rubocop:disable Naming/FileName -- Backward-compatibility alias for the relocated Search::Elastic::Helper constant; removed once references migrate (#398183)
# frozen_string_literal: true

module Gitlab
  module Elastic
    # Backward-compatibility alias. The implementation moved to
    # Search::Elastic::Helper as part of the namespace migration (#398183).
    # This shim keeps the old constant resolving while call sites are migrated
    # in follow-up MRs, and is removed once no references remain.
    Helper = ::Search::Elastic::Helper
  end
end
# rubocop:enable Naming/FileName
