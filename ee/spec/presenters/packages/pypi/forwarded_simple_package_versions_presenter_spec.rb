# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Pypi::ForwardedSimplePackageVersionsPresenter, :aggregate_failures, feature_category: :package_registry do
  let(:project) { build_stubbed(:project) }

  let(:package_name) { 'requests' }
  let(:allowed_hosts) { %w[files.pythonhosted.org] }
  let(:files) do
    [
      { 'filename' => 'requests-2.31.0.tar.gz',
        'url' => 'https://files.pythonhosted.org/p/requests-2.31.0.tar.gz',
        'hashes' => { 'sha256' => 'aaa' }, 'requires-python' => '>=3.7' },
      { 'filename' => 'foo-1.0.tar.gz',
        'url' => 'https://evil.example.com/p/foo-1.0.tar.gz',
        'hashes' => { 'sha256' => 'ccc' } }
    ]
  end

  subject(:presenter) do
    described_class.new(package_name: package_name, files: files, project: project, allowed_hosts: allowed_hosts)
  end

  describe '#body' do
    let(:html) { presenter.body }

    it 'renders the CE Simple-page shape with one allowed-host link' do
      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('<h1>Links for requests</h1>')
      expect(html.scan('<a ').size).to eq(1)
      expect(html).not_to include('evil.example.com')
    end

    it 'rewrites the link back to GitLab via expose_url' do
      expect(html).to include("/api/v4/projects/#{project.id}/packages/pypi/files/aaa/requests-2.31.0.tar.gz")
    end

    context 'with breakout characters in the filename' do
      let(:package_name) { 'evil' }
      let(:files) do
        [{ 'filename' => 'evil-1.0"><script>alert(1)</script>.tar.gz',
           'url' => 'https://files.pythonhosted.org/p/evil-1.0.tar.gz',
           'hashes' => { 'sha256' => 'aaa' } }]
      end

      it 'escapes them' do
        expect(html).not_to include('"><script>')
      end
    end

    context 'with breakout characters in the sha256' do
      let(:files) do
        [{ 'filename' => 'requests-2.31.0.tar.gz',
           'url' => 'https://files.pythonhosted.org/p/requests-2.31.0.tar.gz',
           'hashes' => { 'sha256' => 'aaa"><script>alert(1)</script>' } }]
      end

      it 'escapes them' do
        expect(html).not_to include('"><script>')
      end
    end
  end
end
