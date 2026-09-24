# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CarrierWave::Storage::Fog::File', feature_category: :shared do
  let(:uploader_class) { Class.new(CarrierWave::Uploader::Base) }
  let(:uploader) { uploader_class.new }
  let(:storage) { CarrierWave::Storage::Fog.new(uploader) }
  let(:bucket_name) { 'some-bucket' }
  let(:connection) { ::Fog::Storage.new(connection_options) }
  let(:bucket) { connection.directories.new(key: bucket_name) }
  let(:test_data) { File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml')) }
  let(:directory) { connection.directories.new(key: bucket_name, public: false) }
  let(:connection_options) do
    {
      provider: 'AWS',
      aws_access_key_id: 'AWS_ACCESS_KEY',
      aws_secret_access_key: 'AWS_SECRET_KEY'
    }
  end

  let(:new_file) { CarrierWave::Storage::Fog::File.new(uploader, storage, test_filename) }

  before do
    stub_object_storage(connection_params: connection_options, remote_directory: bucket_name)
    allow(uploader).to receive_messages(fog_directory: bucket_name, fog_credentials: connection_options)
    bucket.files.create(key: test_filename, body: test_data)
  end

  shared_examples 'stores the file using original #store method' do
    it do
      expect(new_file).to receive(:copy_to).with(new_file.path).and_return(new_file)
      result = new_file.store(new_file)
      expect(result).to be true
    end
  end

  describe '#store' do
    context 'when the file is not of the same class and path does not start with a secure directory' do
      let(:test_filename) { 'test.jpg' }

      it_behaves_like 'stores the file using original #store method'
    end

    context 'when the file is of the same class and path starts with a secure directory' do
      let(:test_filename) { '@hashed/some_path' }

      it 'stores the file with custom attributes' do
        expect_any_instance_of(Fog::AWS::Storage::Files).to receive(:create).with({
          body: new_file.read,
          content_type: new_file.content_type,
          key: test_filename,
          public: uploader.fog_public
        }.merge(uploader.fog_attributes)).and_return(true)

        result = new_file.store(new_file)

        expect(result).to be true
      end

      context 'when an error is raised' do
        before do
          allow_any_instance_of(Fog::AWS::Storage::Files).to receive(:create).and_raise(StandardError)
        end

        it_behaves_like 'stores the file using original #store method'
      end

      context 'when direct upload to final path feature flag is disabled' do
        before do
          stub_feature_flags(ff_direct_upload_to_final_path: false)
        end

        it_behaves_like 'stores the file using original #store method'
      end
    end
  end
end
