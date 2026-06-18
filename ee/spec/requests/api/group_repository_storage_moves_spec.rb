# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::GroupRepositoryStorageMoves, feature_category: :gitaly do
  let_it_be(:user, freeze: false) { create(:admin) }
  let_it_be(:container, freeze: false) { create(:group, :wiki_repo) }
  let_it_be(:storage_move, freeze: false) { create(:group_repository_storage_move, :scheduled, container: container) }

  it_behaves_like 'repository_storage_moves API', 'groups' do
    let(:repository_storage_move_factory) { :group_repository_storage_move }
    let(:bulk_worker_klass) { Groups::ScheduleBulkRepositoryShardMovesWorker }
  end
end
