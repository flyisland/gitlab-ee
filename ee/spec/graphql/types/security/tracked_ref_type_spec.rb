# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Security::TrackedRefType, feature_category: :vulnerability_management do
  include GraphqlHelpers
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  before_all { project.add_developer(user) }

  specify { expect(described_class).to require_graphql_authorizations(:read_security_project_tracked_ref) }

  describe 'custom field resolvers' do
    let_it_be(:tracked_ref) { create(:security_project_tracked_context, :tracked, project: project) }
    let(:type_instance) { described_class.send(:new, tracked_ref, {}) }

    describe '#state' do
      it 'uses method delegation to object state' do
        expect(tracked_ref.state).to eq(Security::ProjectTrackedContext::STATES[:tracked])
      end

      context 'with different state values' do
        where(:state_value, :description) do
          Security::ProjectTrackedContext::STATES[:tracked]   | 'tracked state'
          Security::ProjectTrackedContext::STATES[:untracked] | 'untracked state'
        end

        with_them do
          it "correctly returns #{params[:description]}" do
            allow(tracked_ref).to receive(:state).and_return(state_value)

            expect(tracked_ref.state).to eq(state_value)
          end
        end
      end
    end

    describe '#vulnerabilities_count' do
      let_it_be(:expected_reads) do
        create_list(:vulnerability_read, 5, project: project, tracked_context: tracked_ref)
      end

      let_it_be(:other_reads) do
        create_list(:vulnerability_read, 5)
      end

      it 'returns count of vulnerability reads' do
        expect(type_instance.vulnerabilities_count).to eq(expected_reads.count)
      end
    end

    describe '#protected?' do
      before do
        allow(type_instance).to receive_messages(project: project)
      end

      where(:context_type, :ref_exists, :has_protected_match, :expected_result) do
        :branch   | true  | true  | true
        :branch   | true  | false | false
        :branch   | false | false | false
        :tag      | true  | true  | true
        :tag      | true  | false | false
        :tag      | false | false | false
        :unknown  | true  | false | false
      end

      with_them do
        it "returns correct protection status" do
          allow(type_instance).to receive(:ref_exists_in_repository?).and_return(ref_exists)
          allow(tracked_ref).to receive(:context_type).and_return(context_type)

          if context_type == :branch
            matching_result = has_protected_match ? [instance_double(ProtectedBranch)] : []
            allow(project).to receive_message_chain(:protected_branches, :matching).and_return(matching_result)
          elsif context_type == :tag
            matching_result = has_protected_match ? [instance_double(ProtectedTag)] : []
            allow(project).to receive_message_chain(:protected_tags, :matching).and_return(matching_result)
          end

          expect(type_instance.protected?).to eq(expected_result)
        end
      end
    end

    describe '#commit' do
      before do
        allow(type_instance).to receive(:project).and_return(project)
      end

      context 'when ref does not exist in repository' do
        it 'returns nil' do
          allow(type_instance).to receive(:ref_exists_in_repository?).and_return(false)
          expect(type_instance.commit).to be_nil
        end
      end

      context 'when ref exists in repository' do
        before do
          allow(type_instance).to receive(:ref_exists_in_repository?).and_return(true)
        end

        where(:context_type, :ref_name, :has_commit, :expected_result) do
          :branch  | 'main'    | true  | :commit_object
          :branch  | 'main'    | false | nil
          :tag     | 'v1.0.0'  | true  | :commit_object
          :tag     | 'v1.0.0'  | false | nil
        end

        with_them do
          it "handles #{params[:context_type]} context returning #{params[:expected_result] || 'nil'}" do
            allow(tracked_ref).to receive_messages(
              context_type: context_type,
              context_name: ref_name
            )

            qualified_ref = case context_type
                            when :branch then "#{Gitlab::Git::BRANCH_REF_PREFIX}#{ref_name}"
                            when :tag then "#{Gitlab::Git::TAG_REF_PREFIX}#{ref_name}"
                            end

            commit_result = has_commit ? instance_double(Commit) : nil
            allow(project).to receive_message_chain(:repository, :commit)
              .with(qualified_ref).and_return(commit_result)

            result = type_instance.commit

            if expected_result == :commit_object && has_commit
              expect(result).to be_present
            else
              expect(result).to be_nil
            end
          end
        end

        context 'when context type is unknown' do
          it 'returns nil' do
            allow(tracked_ref).to receive_messages(
              context_type: :unknown,
              context_name: 'ref'
            )

            allow(project).to receive_message_chain(:repository, :commit)
              .with(nil).and_return(nil)

            expect(type_instance.commit).to be_nil
          end
        end
      end
    end

    describe '#ref_exists_in_repository?' do
      before do
        allow(type_instance).to receive(:project).and_return(project)
      end

      where(:repository_exists, :context_type, :ref_exists_result, :expected_result) do
        false   | :branch   | true  | false
        false   | :tag      | true  | false
        false   | :unknown  | true  | false
        true    | :branch   | true  | true
        true    | :branch   | false | false
        true    | :tag      | true  | true
        true    | :tag      | false | false
        true    | :unknown  | true  | false
        true    | :invalid  | true  | false
        true    | ''        | true  | false
      end

      with_them do
        it "handles different repository and context scenarios" do
          allow(project).to receive(:repository_exists?).and_return(repository_exists)
          allow(tracked_ref).to receive(:context_type).and_return(context_type)

          if repository_exists && context_type == :branch
            allow(project).to receive_message_chain(:repository, :branch_exists?).and_return(ref_exists_result)
          elsif repository_exists && context_type == :tag
            allow(project).to receive_message_chain(:repository, :tag_exists?).and_return(ref_exists_result)
          end

          expect(type_instance.send(:ref_exists_in_repository?)).to eq(expected_result)
        end
      end

      it 'memoizes repository checks for the same tracked ref' do
        allow(project).to receive(:repository_exists?).once.and_return(true)
        allow(tracked_ref).to receive_messages(context_type: :branch, context_name: 'main')
        allow(project.repository).to receive(:branch_exists?).with('main').once.and_return(true)

        expect(type_instance.send(:ref_exists_in_repository?)).to be(true)
        expect(type_instance.send(:ref_exists_in_repository?)).to be(true)
      end
    end

    describe 'connection type' do
      it 'uses CountableConnectionType for pagination with count' do
        expect(described_class.connection_type_class).to eq(Types::CountableConnectionType)
      end
    end
  end

  describe 'field call count limits' do
    let(:call_count_limit) { described_class::MAX_GITALY_FIELD_CALLS }

    it 'limits commit field calls' do
      extension = described_class.fields['commit'].extensions.find do |ext|
        ext.is_a?(::Gitlab::Graphql::Limit::FieldCallCount)
      end

      expect(extension).to be_present
      expect(extension.options[:limit]).to eq(call_count_limit)
    end

    it 'limits isProtected field calls' do
      extension = described_class.fields['isProtected'].extensions.find do |ext|
        ext.is_a?(::Gitlab::Graphql::Limit::FieldCallCount)
      end

      expect(extension).to be_present
      expect(extension.options[:limit]).to eq(call_count_limit)
    end
  end
end
