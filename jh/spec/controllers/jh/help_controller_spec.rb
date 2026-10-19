# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HelpController, feature_category: :pages do
  include StubVersion
  include DocUrlHelper

  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  shared_examples 'fetch available doc path' do |documentation_base_url|
    let(:gitlab_version) { version }
    let(:path) { 'user/ssh' }
    let(:prefix) { documentation_base_url&.end_with?('docs.gitlab.com') ? '' : 'jh/' }
    let(:suffix) { documentation_base_url&.end_with?('docs.gitlab.com') ? '/' : '.html' }

    before do
      controller.instance_variable_set(:@path, path)
      allow(controller).to receive(:documentation_base_url).and_return(documentation_base_url)
      stub_version(gitlab_version, 'ignored_revision_value')
    end

    it 'get right doc path with a specified version' do
      expect(subject.send(:documentation_file_path)).to eq("13.4/#{prefix}#{path}#{suffix}")
    end

    context 'when it is a pre-release' do
      let(:gitlab_version) { '13.4.0-pre' }

      it 'get right doc path without a version' do
        expect(subject.send(:documentation_file_path)).to eq("#{prefix}#{path}#{suffix}")
      end
    end
  end

  shared_examples 'when user with English preferred language' do
    context 'when there are the English document in jh directory' do
      before do
        allow(File).to receive(:exist?).with(Rails.root.join('jh/doc-en/en.md').to_s).and_return(true)
      end

      it 'returns the jh English document path' do
        expect(subject.send(:path_to_doc, 'en.md')).to eq(Rails.root.join('jh/doc-en/en.md').to_s)
      end
    end

    context 'when there are not the English document in jh directory' do
      it 'returns the gitlab English document path' do
        expect(subject.send(:path_to_doc, 'test.md')).to eq(Rails.root.join('doc/test.md').to_s)
      end
    end
  end

  describe '#path_to_doc' do
    context 'when user with English preferred language' do
      before do
        user.update(preferred_language: 'en')
      end

      it_behaves_like 'when user with English preferred language'
    end

    context 'when user with Chinese preferred language' do
      before do
        user.update(preferred_language: 'zh_CN')
      end

      # rubocop: disable RSpec/NamedSubject -- We cannot name it as it is used to test private method
      it 'returns the Chinese document path' do
        expect(subject.send(:path_to_doc, 'README.md')).to eq(Rails.root.join('jh/doc/README.md').to_s)
      end
      # rubocop: enable RSpec/NamedSubject
    end

    context 'when user with other preferred language' do
      before do
        user.update(preferred_language: 'ru')
      end

      it_behaves_like 'when user with English preferred language'
    end
  end

  describe '#documentation_file_path' do
    context 'when fetch english doc path' do
      context 'with help_page_documentation_url use https' do
        it_behaves_like 'fetch available doc path', 'https://docs.gitlab.com'
      end

      context 'with help_page_documentation_url use http' do
        it_behaves_like 'fetch available doc path', 'http://docs.gitlab.com'
      end
    end

    context 'when fetch chinese doc path' do
      context 'with help_page_documentation_url is not set' do
        it_behaves_like 'fetch available doc path', nil
      end

      context 'with help_page_documentation_url is not set as original url' do
        it_behaves_like 'fetch available doc path', 'http://docs.gitlab.cn'
      end

      context 'when path ends with _index' do
        before do
          allow(controller).to receive(:documentation_base_url).and_return('http://docs.gitlab.cn')
          stub_version('13.4.0', 'ignored_revision_value')
          controller.instance_variable_set(:@path, 'user/packages/package_registry/_index')
        end

        it 'converts to index.html without double slashes' do
          expect(controller.send(:documentation_file_path)).to eq('13.4/jh/user/packages/package_registry/index.html')
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when requesting help index (underscore prefix test)' do
      subject(:result) { get :index }

      before do
        stub_application_setting(help_page_documentation_base_url: '')
        stub_doc_file_read(content: '_index.md content', file_name: '_index.md')

        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join('doc/index.md').to_s).and_return(false)
        allow(File).to receive(:exist?).with(Rails.root.join('doc/_index.md').to_s).and_return(true)
        allow(File).to receive(:exist?).with(Rails.root.join('jh/doc-en/index.md').to_s).and_return(false)
        allow(File).to receive(:exist?).with(Rails.root.join('jh/doc-en/_index.md').to_s).and_return(true)
      end

      context 'with the doc/index.md file does not exist' do
        it 'returns _index.md' do
          expect(result).to be_successful
          expect(assigns[:help_index]).to eq '_index.md content'
        end
      end
    end

    context 'when requesting an index.md' do
      let(:path) { 'index' }

      subject(:result) { get :show, params: { path: path }, format: :md }

      before do
        stub_application_setting(help_page_documentation_base_url: '')
        stub_doc_file_read(content: '_index.md content', file_name: '_index.md')

        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join('doc/index.md').to_s).and_return(false)
        allow(File).to receive(:exist?).with(Rails.root.join('doc/_index.md').to_s).and_return(true)
        allow(File).to receive(:exist?).with(Rails.root.join('jh/doc-en/index.md').to_s).and_return(false)
        allow(File).to receive(:exist?).with(Rails.root.join('jh/doc-en/_index.md').to_s).and_return(true)
      end

      context 'with the index.md file does not exist' do
        it 'returns an _index.md file' do
          expect(result).to be_successful
          expect(assigns[:markdown]).to eq '_index.md content'
        end
      end
    end
  end

  describe 'GET #docs' do
    subject(:get_redirect_to_docs) { get :redirect_to_docs }

    before do
      stub_application_setting(help_page_documentation_base_url: custom_docs_url)
    end

    context 'with no custom docs URL configured' do
      let(:custom_docs_url) { nil }

      it 'redirects to docs.gitlab.cn' do
        get_redirect_to_docs

        expect(response).to redirect_to('https://docs.gitlab.cn')
      end
    end
  end
end
