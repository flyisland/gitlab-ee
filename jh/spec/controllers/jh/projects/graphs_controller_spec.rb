# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::GraphsController do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  subject(:gon_features) do
    get(:show, params: { namespace_id: project.namespace.path, project_id: project.path, id: 'master' })

    Gon.get_variable('features').fetch('linesOfCode')
  end

  describe '#show' do
    subject(:graph) do
      get(:show,
        params: { namespace_id: project.namespace.path, project_id: project.path, id: 'master' },
        format: :json)

      Gitlab::Json.parse(response.body).sample.keys.sort
    end

    context 'with real_lines_of_code license' do
      before do
        stub_licensed_features(real_lines_of_code: true)
      end

      it 'renders graph with LOC' do
        expect(graph).to contain_exactly(
          'additions',
          'author_email',
          'author_name',
          'date',
          'deletions',
          'effective_additions',
          'effective_deletions',
          'id')
        expect(gon_features).to be true
      end
    end

    context 'without real_lines_of_code license' do
      before do
        stub_licensed_features(real_lines_of_code: false)
      end

      it 'renders graph without LOC' do
        expect(graph).to contain_exactly('author_email', 'author_name', 'date')
        expect(gon_features).to be false
      end
    end
  end
end
