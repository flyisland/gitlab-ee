# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArtifactRegistry::SelectsPermissions, feature_category: :artifact_registry do
  include GraphqlHelpers

  let(:resolver_class) do
    Class.new(Resolvers::BaseResolver) do
      include ::ArtifactRegistry::SelectsPermissions

      def selected?(lookahead)
        permissions_selected?(lookahead)
      end
    end
  end

  let(:resolver) { resolver_class.new(object: nil, context: query_context(user: nil), field: nil) }

  it 'asks the field for the lookahead extra' do
    expect(resolver_class.extras).to include(:lookahead)
  end

  describe '#permissions_selected?' do
    it 'is true when the selection includes userPermissions' do
      lookahead = instance_double(GraphQL::Execution::Lookahead)
      allow(lookahead).to receive(:selects?).with(:user_permissions).and_return(true)

      expect(resolver.selected?(lookahead)).to be(true)
    end

    it 'is false when the selection omits userPermissions' do
      expect(resolver.selected?(negative_lookahead)).to be(false)
    end
  end
end
