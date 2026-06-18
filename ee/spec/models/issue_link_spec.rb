# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssueLink, feature_category: :portfolio_management do
  it_behaves_like 'includes LinkableItem concern (EE)' do
    let_it_be(:item_factory, freeze: false) { :issue }
    let_it_be(:link_factory, freeze: false) { :issue_link }
    let_it_be(:link_class, freeze: false) { described_class }
  end
end
