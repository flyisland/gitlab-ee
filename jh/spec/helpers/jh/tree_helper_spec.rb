# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::TreeHelper, feature_category: :source_code_management do
  describe 'download_links' do
    let_it_be(:project) { build_stubbed(:project, :repository) }
    let(:ref) { 'master' }
    let(:archive_prefix) { 'archive' }
    let(:ref_type) { 'head' }

    it 'returns nil if the download button is disabled' do
      allow(::Gitlab::CurrentSettings).to receive(:disable_download_button_enabled?).and_return(true)

      expect(helper.download_links(project, ref, archive_prefix, ref_type).length).to eq(0)
    end

    it 'calls super if the download button is enabled' do
      allow(::Gitlab::CurrentSettings).to receive(:disable_download_button_enabled?).and_return(false)
      allow(project).to receive(:empty_repo?).and_return(false)

      expect(helper.download_links(project, ref, archive_prefix, ref_type).length).to eq(4)
    end
  end
end
