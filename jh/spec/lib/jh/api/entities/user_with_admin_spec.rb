# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::API::Entities::UserWithAdmin do
  let(:preferred_language) { 'zh_CN' }
  let(:user) { create(:user, :with_namespace, preferred_language: preferred_language) }
  let(:entity) { described_class.new(user) }

  subject(:entity_as_json) { entity.as_json }

  context 'with user specified preferred_language' do
    it 'renders the string' do
      expect(entity_as_json[:preferred_language]).to eq preferred_language
    end
  end
end
