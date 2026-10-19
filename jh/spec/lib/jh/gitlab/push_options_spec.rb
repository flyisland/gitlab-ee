# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe 'JH::Gitlab::PushOptions', feature_category: :source_code_management do
  require_relative '../../../../lib/jh/gitlab/push_options'

  describe 'JH extensions to Gitlab::PushOptions' do
    describe 'VALID_OPTIONS constant' do
      it 'includes skip_mono_central_pipeline in merge_request keys' do
        expect(Gitlab::PushOptions::VALID_OPTIONS[:merge_request][:keys]).to include(:skip_mono_central_pipeline)
      end

      it 'preserves original merge_request keys' do
        original_keys = [:create, :target, :title, :description, :label, :unlabel, :assign, :unassign,
          :milestone, :remove_source_branch, :squash]

        original_keys.each do |key|
          expect(Gitlab::PushOptions::VALID_OPTIONS[:merge_request][:keys]).to include(key)
        end
      end
    end

    describe 'option validation through parsing' do
      it 'successfully parses skip_mono_central_pipeline as a valid merge_request option' do
        options = Gitlab::PushOptions.new(['merge_request.skip_mono_central_pipeline=true'])

        expect(options.get(:merge_request, :skip_mono_central_pipeline)).to eq('true')
        expect(options.get(:merge_request)).to include(skip_mono_central_pipeline: 'true')
      end

      it 'successfully parses skip_mono_central_pipeline with boolean flag' do
        options = Gitlab::PushOptions.new(['merge_request.skip_mono_central_pipeline'])

        expect(options.get(:merge_request, :skip_mono_central_pipeline)).to be(true)
      end

      it 'validates other existing merge_request options still work' do
        options = Gitlab::PushOptions.new([
          'merge_request.create',
          'merge_request.target=main',
          'merge_request.title=Test'
        ])

        expect(options.get(:merge_request, :create)).to be(true)
        expect(options.get(:merge_request, :target)).to eq('main')
        expect(options.get(:merge_request, :title)).to eq('Test')
      end

      it 'ignores invalid merge_request options' do
        options = Gitlab::PushOptions.new(['merge_request.invalid_option=value'])

        expect(options.get(:merge_request)).to be_nil
      end

      it 'ignores invalid namespaces' do
        options = Gitlab::PushOptions.new(['invalid_namespace.skip_mono_central_pipeline=true'])

        expect(options.get(:invalid_namespace)).to be_nil
      end
    end
  end
end
