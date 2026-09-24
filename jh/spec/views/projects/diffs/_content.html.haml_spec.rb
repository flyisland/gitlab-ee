# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/diffs/_content.html.haml', feature_category: :source_code_management do
  let(:project) { build_stubbed(:project) }
  let(:commit) { build(:commit, project: project) }
  let(:diff_file) do
    instance_double(Gitlab::Diff::File, file_path: 'file.txt', has_renderable?: false,
      viewer: nil, blob: instance_double(Gitlab::Git::Blob, path: 'file.txt'))
  end

  before do
    stub_template('projects/diffs/_viewer.html.haml' => 'Diff content')
  end

  it 'renders the diff without a diff collection' do
    render partial: 'projects/diffs/content', locals: { diff_file: diff_file }

    expect(rendered).to have_content('Diff content')
  end

  context 'with a commit diff collection' do
    let(:content_blocked_state) { nil }

    before do
      assign(:diffs, instance_double(Gitlab::Diff::FileCollection::Base, diffable: commit))
      allow(ContentValidation::Setting).to receive(:block_enabled?).with(project).and_return(true)
      allow(ContentValidation::ContentBlockedState).to receive(:find_by_container_commit_path)
        .with(project, commit.sha, 'file.txt').and_return(content_blocked_state)
    end

    it 'renders unblocked content' do
      render partial: 'projects/diffs/content', locals: { diff_file: diff_file }

      expect(rendered).to have_content('Diff content')
    end

    context 'when the content is blocked' do
      let(:content_blocked_state) { build(:content_blocked_state, container: project) }

      it 'renders the blocked content message' do
        render partial: 'projects/diffs/content', locals: { diff_file: diff_file }

        expect(rendered).to have_content(
          s_('JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed.')
        )
        expect(rendered).not_to have_content('Diff content')
      end
    end
  end
end
