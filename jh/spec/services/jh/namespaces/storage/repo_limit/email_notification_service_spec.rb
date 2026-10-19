# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Namespaces::Storage::RepoLimit::EmailNotificationService,
  :use_clean_rails_memory_store_caching,
  feature_category: :consumables_cost_management do
  using RSpec::Parameterized::TableSyntax

  let(:mailer) { ::JH::Namespaces::Storage::RepoLimitMailer }
  let(:action_mailer) { instance_double(ActionMailer::MessageDelivery) }
  let(:owner) { build_stubbed(:user) }
  let(:group) { build_stubbed(:group, owner: owner) }
  let(:project_statistics) { build_stubbed(:project_statistics) }
  let(:project) { build_stubbed(:project, creator: owner, statistics: project_statistics, group: group) }

  # Sizes are in megabytes.
  let(:actual_size_limit) { 100 }
  let(:additional_purchased_storage_size) { 0 }
  let(:repository_size) { 0 }
  let(:lfs_objects_size) { 0 }
  let(:repository_size_excess) { 0 }

  before do
    allow(project).to receive(:root_ancestor).and_return(group)
    allow(group).to receive_messages(
      owners_emails: [owner.email],
      actual_size_limit: actual_size_limit.megabytes,
      additional_purchased_storage_size: additional_purchased_storage_size,
      total_repository_size_excess: repository_size_excess.megabytes
    )
    allow(project_statistics).to receive_messages(
      repository_size: repository_size.megabytes,
      lfs_objects_size: lfs_objects_size.megabytes
    )
  end

  shared_examples 'sends an out-of-storage notification' do
    it 'sends an out-of-storage notification', :aggregate_failures do
      expect(mailer).to receive(:notify_out_of_storage)
        .with(
          project: project, recipients: [owner.email],
          usage_percentage: (repository_size + lfs_objects_size).floor(1)
        )
        .and_return(action_mailer)
      expect(action_mailer).to receive(:deliver_later)

      described_class.execute(project)
    end
  end

  shared_examples 'sends a limit warning notification' do
    it 'sends a limit warning notification', :aggregate_failures do
      expect(mailer).to receive(:notify_limit_warning)
        .with(
          project: project, recipients: [owner.email],
          usage_percentage: (repository_size + lfs_objects_size).floor(1)
        )
        .and_return(action_mailer)
      expect(action_mailer).to receive(:deliver_later)

      described_class.execute(project)
    end
  end

  shared_examples 'sends a group out-of-storage notification' do
    it 'sends a group out-of-storage notification', :aggregate_failures do
      expect(mailer).to receive(:notify_group_out_of_storage)
        .with(namespace: group, recipients: [owner.email], usage_percentage: repository_size_excess)
        .and_return(action_mailer)
      expect(action_mailer).to receive(:deliver_later)
      expect(mailer).not_to receive(:notify_out_of_storage)
      expect(mailer).not_to receive(:notify_limit_warning)

      described_class.execute(project)
    end
  end

  shared_examples 'sends a group limit warning notification' do
    it 'sends a group limit warning notification', :aggregate_failures do
      expect(mailer).to receive(:notify_group_limit_warning)
        .with(namespace: group, recipients: [owner.email], usage_percentage: repository_size_excess)
        .and_return(action_mailer)
      expect(action_mailer).to receive(:deliver_later)
      expect(mailer).not_to receive(:notify_out_of_storage)
      expect(mailer).not_to receive(:notify_limit_warning)

      described_class.execute(project)
    end
  end

  shared_examples 'does not send any notification' do
    it 'does not send any notification', :aggregate_failures do
      expect(mailer).not_to receive(:notify_out_of_storage)
      expect(mailer).not_to receive(:notify_limit_warning)
      expect(mailer).not_to receive(:notify_group_out_of_storage)
      expect(mailer).not_to receive(:notify_group_limit_warning)

      described_class.execute(project)
    end
  end

  context 'when the notice is enabled', :saas do
    before do
      stub_feature_flags(jh_saas_storage_limit_notice: true)
    end

    context 'when owners use different languages' do
      let(:other_owner) { build_stubbed(:user, preferred_language: 'zh_CN') }

      before do
        allow(group).to receive(:owners_emails).and_return([owner.email, other_owner.email])
      end

      where(:repository_size, :additional_purchased_storage_size, :repository_size_excess, :notification_method) do
        90  | 0   | 0   | :notify_limit_warning
        100 | 0   | 0   | :notify_out_of_storage
        100 | 100 | 90  | :notify_group_limit_warning
        100 | 100 | 100 | :notify_group_out_of_storage
      end

      with_them do
        it 'queues a separate email for each owner once within the cooldown', :aggregate_failures do
          expect(::Gitlab::ErrorTracking).not_to receive(:track_exception)
          expect(mailer).to receive(notification_method)
            .with(hash_including(recipients: [owner.email])).once.and_return(action_mailer)
          expect(mailer).to receive(notification_method)
            .with(hash_including(recipients: [other_owner.email])).once.and_return(action_mailer)
          expect(action_mailer).to receive(:deliver_later).twice

          described_class.execute(project)
          described_class.execute(project)
        end
      end
    end

    context 'when the project belongs to a personal namespace' do
      let(:namespace) { build_stubbed(:user_namespace, owner: owner) }
      let(:project) { build_stubbed(:project, namespace: namespace, statistics: project_statistics) }

      before do
        allow(project).to receive(:root_ancestor).and_return(namespace)
        allow(namespace).to receive_messages(
          actual_size_limit: actual_size_limit.megabytes,
          additional_purchased_storage_size: 0,
          total_repository_size_excess: 0
        )
      end

      where(:repository_size, :notification_method) do
        90    | :notify_limit_warning
        99.99 | :notify_limit_warning
        100   | :notify_out_of_storage
      end

      with_them do
        it 'notifies the owner and skips repeat notifications within the cooldown', :aggregate_failures do
          expect(::Gitlab::ErrorTracking).not_to receive(:track_exception)
          expect(mailer).to receive(notification_method)
            .with(
              project: project, recipients: [owner.email],
              usage_percentage: (repository_size + lfs_objects_size).floor(1)
            )
            .once.and_return(action_mailer)
          expect(action_mailer).to receive(:deliver_later).once

          described_class.execute(project)

          travel 29.minutes do
            described_class.execute(project)
          end
        end
      end
    end

    context 'when no additional storage has been purchased' do
      context 'when included usage is below 90%' do
        where(:repository_size) { [0, 50, 89] }

        with_them do
          it_behaves_like 'does not send any notification'
        end
      end

      context 'when included usage is from 90% up to the limit' do
        where(:repository_size) { [90, 99] }

        with_them do
          it_behaves_like 'sends a limit warning notification'
        end
      end

      context 'when included usage reaches the limit' do
        where(:repository_size) { [100, 150] }

        with_them do
          it_behaves_like 'sends an out-of-storage notification'
        end
      end

      context 'when LFS objects push usage to the limit' do
        let(:repository_size) { 80 }
        let(:lfs_objects_size) { 20 }

        it_behaves_like 'sends an out-of-storage notification'
      end

      context 'when the size limit is 0' do
        let(:actual_size_limit) { 0 }
        let(:repository_size) { 150 }

        it_behaves_like 'does not send any notification'
      end
    end

    context 'when additional storage was purchased but not used' do
      let(:additional_purchased_storage_size) { 100 }

      context 'when included usage is below 90%' do
        let(:repository_size) { 50 }

        it_behaves_like 'does not send any notification'
      end

      context 'when included usage is from 90% up to the limit' do
        let(:repository_size) { 90 }

        it_behaves_like 'sends a limit warning notification'
      end

      context 'when included usage reaches the limit' do
        let(:repository_size) { 100 }

        it_behaves_like 'sends an out-of-storage notification'
      end
    end

    context 'when purchased storage usage is below 90%' do
      let(:additional_purchased_storage_size) { 100 }
      let(:repository_size) { 150 }
      let(:repository_size_excess) { 50 }

      it_behaves_like 'does not send any notification'
    end

    context 'when purchased storage usage is from 90% up to the purchased limit' do
      let(:additional_purchased_storage_size) { 100 }
      let(:repository_size) { 10 }

      where(:repository_size_excess) { [90, 99] }

      with_them do
        it_behaves_like 'sends a group limit warning notification'
      end
    end

    context 'when purchased storage usage reaches the purchased limit' do
      let(:additional_purchased_storage_size) { 100 }
      let(:repository_size) { 10 }

      where(:repository_size_excess) { [100, 150] }

      with_them do
        it_behaves_like 'sends a group out-of-storage notification'
      end
    end

    context 'when another project in the group reaches the same purchased-storage level' do
      let(:additional_purchased_storage_size) { 100 }
      let(:repository_size_excess) { 100 }
      let(:other_project) { build_stubbed(:project, statistics: project_statistics, group: group) }

      before do
        allow(other_project).to receive(:root_ancestor).and_return(group)
      end

      it 'sends one group notification within 30 minutes' do
        allow(mailer).to receive(:notify_group_out_of_storage).and_return(action_mailer)
        expect(action_mailer).to receive(:deliver_later).once

        described_class.execute(project)

        expect(mailer).not_to receive(:notify_group_out_of_storage)

        described_class.execute(other_project)
      end
    end

    context 'when the notification level is unchanged' do
      let(:repository_size) { 150 }

      it 'skips another notification within 30 minutes' do
        allow(mailer).to receive(:notify_out_of_storage).and_return(action_mailer)
        expect(action_mailer).to receive(:deliver_later).once

        described_class.execute(project)

        expect(mailer).not_to receive(:notify_out_of_storage)
        expect(mailer).not_to receive(:notify_limit_warning)

        travel_to(29.minutes.from_now) do
          described_class.execute(project)
        end
      end

      it 'sends again once 30 minutes have passed' do
        allow(mailer).to receive(:notify_out_of_storage).and_return(action_mailer)
        expect(action_mailer).to receive(:deliver_later).twice

        described_class.execute(project)

        travel 31.minutes do
          expect(mailer).to receive(:notify_out_of_storage)
            .with(
              project: project, recipients: [owner.email],
              usage_percentage: (repository_size + lfs_objects_size).floor(1)
            )
            .and_return(action_mailer)

          described_class.execute(project)
        end
      end
    end

    context 'when the notification level changes within 30 minutes' do
      it 'sends the notification for the new level' do
        allow(project_statistics).to receive(:repository_size).and_return(90.megabytes)
        allow(mailer).to receive(:notify_limit_warning).and_return(action_mailer)
        allow(action_mailer).to receive(:deliver_later)

        described_class.execute(project)

        allow(project_statistics).to receive(:repository_size).and_return(100.megabytes)

        expect(mailer).to receive(:notify_out_of_storage)
          .with(project: project, recipients: [owner.email], usage_percentage: 100)
          .and_return(action_mailer)
        expect(action_mailer).to receive(:deliver_later)

        described_class.execute(project)
      end
    end
  end

  context 'when sending the notification fails', :saas do
    let(:repository_size) { 150 }

    before do
      stub_feature_flags(jh_saas_storage_limit_notice: true)
    end

    it 'tracks the exception and does not raise' do
      error = StandardError.new('mail failed')

      allow(mailer).to receive(:notify_out_of_storage).and_raise(error)
      expect(::Gitlab::ErrorTracking).to receive(:track_exception).with(
        error,
        class: described_class.name,
        project_id: project.id
      )

      expect { described_class.execute(project) }.not_to raise_error
    end
  end

  context 'when the notice is disabled', :saas do
    let(:repository_size) { 150 }

    it_behaves_like 'does not send any notification'
  end

  context 'when not on GitLab.com' do
    let(:repository_size) { 150 }

    before do
      stub_feature_flags(jh_saas_storage_limit_notice: true)
    end

    it_behaves_like 'does not send any notification'
  end
end
