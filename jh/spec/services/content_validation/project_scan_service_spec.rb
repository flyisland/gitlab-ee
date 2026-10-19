# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ProjectScanService do
  let!(:group) { create(:group) }
  let!(:user) { create(:user) }
  let!(:project) { create(:project, :repository, namespace: group) }
  let(:commit) { project.repository.commit }

  let(:root_folder_file) { "README.md" }
  let(:sub_folder_file) { "bar/branch-test.txt" }
  let(:another_sub_folder_file) { "files/html/500.html" }
  let(:binary_file) { "files/images/logo-black.png" }

  describe "#execute" do
    before do
      group.add_owner(user)
      allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
    end

    context "when pre_check_skip return true" do
      before do
        allow_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          allow(client).to receive(:pre_check).and_return(
            instance_double(HTTParty::Response, success?: true, parsed_response: { "skip_validate" => true })
          )
        end
      end

      it "skip validate" do
        expect_next_instance_of(described_class) do |service|
          expect(service).not_to receive(:validate_tree)
          expect(service).not_to receive(:validate_blob)
        end

        described_class.new(project).execute
      end
    end

    context "when with ref option" do
      let(:ref) { "test-ref" }

      it "call repository commit with ref" do
        expect(project.repository).to receive(:commit).with(ref).once.and_call_original

        described_class.new(project, ref: ref).execute
      end
    end

    context "when with scan_path option" do
      let(:scan_path) { "bar" }

      it "call repository tree with scan_path" do
        expect(project.repository).to receive(:tree).with(commit.id, scan_path, recursive: true).once.and_call_original
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).to receive(:blob_validate).with(hash_including(path: sub_folder_file))
          expect(client).not_to receive(:blob_validate).with(hash_including(path: root_folder_file))
          expect(client).not_to receive(:blob_validate).with(hash_including(path: another_sub_folder_file))
        end

        described_class.new(project, scan_path: scan_path).execute
      end
    end

    context "when with recursive option false" do
      let(:recursive) { false }

      it "not validate sub folder file" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).to receive(:blob_validate).with(hash_including(path: root_folder_file))
          expect(client).not_to receive(:blob_validate).with(hash_including(path: sub_folder_file))
          expect(client).not_to receive(:blob_validate).with(hash_including(path: another_sub_folder_file))
        end

        described_class.new(project, recursive: recursive).execute
      end
    end

    context "when with include_binary option true" do
      let(:include_binary) { true }

      before do
        project.repository.write_ref('master', '913c66a')
      end

      it "validate include binary file" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).to receive(:blob_validate).with(hash_including(content_type: "text")).at_least(:once).ordered
          expect(client).to receive(:blob_validate).with(hash_including(content_type: "tree")).at_least(:once).ordered
          expect(client).to receive(:blob_validate).with(hash_including(content_type: "image")).at_least(:once).ordered
        end

        described_class.new(project, include_binary: include_binary).execute
      end

      context "when binary file over limit" do
        before do
          allow_any_instance_of(Gitlab::Git::Blob).to receive(:size).and_return(11.megabytes)
        end

        it "not validate file" do
          expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
            expect(client).not_to receive(:blob_validate).with(hash_including(content_type: "image"))
          end

          described_class.new(project, include_binary: include_binary).execute
        end
      end
    end

    context "when text file over limit" do
      before do
        allow_any_instance_of(Gitlab::Git::Blob).to receive(:size).and_return(3.megabytes)
        project.repository.write_ref('master', '913c66a')
      end

      it "not validate file" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).not_to receive(:blob_validate).with(hash_including(content_type: "text"))
        end

        described_class.new(project).execute
      end
    end

    it "client call blob_validate" do
      expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
        expect(client).to receive(:blob_validate)
          .with(hash_including(container_identifier: "project-#{project.id}",
            project_id: project.id,
            project_full_path: project.full_path,
            group_id: group.id,
            group_full_path: group.full_path,
            repo_type: "project",
            user_id: user.id,
            user_email: user.email,
            user_username: user.username,
            incremental: false)).at_least(:twice)
        expect(client).not_to receive(:blob_validate).with(hash_including(path: binary_file))
      end

      expect_next_instance_of(described_class) do |service|
        expect(service).to receive(:validate_tree).at_least(:once).and_call_original
        expect(service).to receive(:validate_text_blob).at_least(:once).and_call_original
      end

      project.repository.write_ref('master', '913c66a')
      described_class.new(project).execute
    end
  end
end
