# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Pypi::ForwardedSimplePackageVersionsJsonPresenter, :aggregate_failures, feature_category: :package_registry do
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
    let(:parsed) { Gitlab::Json.safe_parse(presenter.body) }
    let(:file) { parsed['files'].first }

    it 'emits PEP 691 meta and the package name' do
      expect(parsed['meta']).to eq('api-version' => '1.0')
      expect(parsed['name']).to eq('requests')
    end

    it 'keeps only the allowed-host file and rewrites the URL back to GitLab via expose_url' do
      expect(parsed['files'].size).to eq(1)
      expect(file['url']).to include("/api/v4/projects/#{project.id}/packages/pypi/files/aaa/requests-2.31.0.tar.gz")
      expect(file['url']).to include('package_name=requests', 'version=2.31.0')
      expect(file['url']).to include('upstream_url=https%3A%2F%2Ffiles.pythonhosted.org')
      expect(file['url']).to end_with('#sha256=aaa')
      # absolute URL (expose_url), so relative_url_root is preserved
      expect(URI.parse(file['url'].split('#').first).host).to be_present
    end

    it 'preserves hashes and requires-python and drops core-metadata' do
      expect(file['hashes']).to eq('sha256' => 'aaa')
      expect(file['requires-python']).to eq('>=3.7')
      expect(file).not_to have_key('core-metadata')
    end

    context 'when a file is missing its sha256' do
      let(:files) do
        [{ 'filename' => 'requests-2.31.0.tar.gz',
           'url' => 'https://files.pythonhosted.org/p/requests-2.31.0.tar.gz', 'hashes' => {} }]
      end

      it 'drops the file' do
        expect(parsed['files']).to be_empty
      end
    end

    describe 'version extraction from the filename' do
      using RSpec::Parameterized::TableSyntax

      let(:files) do
        [{ 'filename' => filename,
           'url' => 'https://files.pythonhosted.org/p/file',
           'hashes' => { 'sha256' => 'aaa' } }]
      end

      where(:case_name, :package_name, :filename, :expected_version) do
        'simple sdist'                         | 'requests'          | 'requests-2.31.0.tar.gz'           | '2.31.0'
        'hyphenated name (not the first dash)' | 'django-allauth'    | 'django-allauth-0.1.tar.gz'        | '0.1'
        'wheel build/platform tags trimmed'    | 'requests'          | 'requests-2.31.0-py3-none-any.whl' | '2.31.0'
        'underscore separator in the filename' | 'typing_extensions' | 'typing_extensions-4.9.0.tar.gz'   | '4.9.0'
        'dotted name, mixed separators'        | 'zope.interface'    | 'zope_interface-6.1.tar.gz'        | '6.1'
        'legacy .tar.bz2 sdist' | 'requests' | 'requests-2.31.0.tar.bz2' | '2.31.0'
      end

      with_them do
        it 'derives the version after the full normalized name prefix' do
          version_param = CGI.parse(URI.parse(file['url']).query)['version'].first

          expect(version_param).to eq(expected_version)
        end
      end

      context 'when the file extension is not recognized' do
        let(:files) do
          [{ 'filename' => 'requests-2.31.0.exe',
             'url' => 'https://files.pythonhosted.org/p/requests-2.31.0.exe',
             'hashes' => { 'sha256' => 'aaa' } }]
        end

        it 'drops the file (fail-safe) rather than emitting an unverifiable version' do
          expect(parsed['files']).to be_empty
        end
      end
    end

    context 'when the filename does not start with the package name' do
      let(:files) do
        [{ 'filename' => 'unrelated-1.0.tar.gz',
           'url' => 'https://files.pythonhosted.org/p/unrelated-1.0.tar.gz',
           'hashes' => { 'sha256' => 'aaa' } }]
      end

      it 'drops the file because no version can be derived' do
        expect(parsed['files']).to be_empty
      end
    end
  end
end
