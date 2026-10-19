# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Namespaces::Storage::RepoLimitMailer, feature_category: :consumables_cost_management do
  include EmailSpec::Matchers
  include GitlabRoutingHelper

  let(:recipients) { %w[bob@example.com john@example.com] }
  let(:project) { build_stubbed(:project, name: 'example-project') }
  let(:project_link) { ActionController::Base.helpers.link_to(project.name, project_url(project)) }

  shared_examples 'uses the recipient language' do |method|
    let_it_be(:recipient) { create(:user, preferred_language: 'zh_CN') }

    it 'localizes the subject and both body formats', :aggregate_failures do
      mail = described_class.public_send(method, **mail_arguments.merge(recipients: [recipient.email])).message
      english_mail = described_class.public_send(method, **mail_arguments.merge(recipients: ['unknown@example.com']))
        .message
      closing = Gitlab::I18n.with_user_locale(recipient) { s_('JH|FreeTrial|Thanks,') }

      expect(mail.subject).not_to eq(english_mail.subject)
      expect(mail.html_part.body.decoded).not_to eq(english_mail.html_part.body.decoded)
      expect(mail.text_part.body.decoded).not_to eq(english_mail.text_part.body.decoded)
      expect(mail.html_part.body.decoded).to include(closing)
      expect(mail.text_part.body.decoded).to include(closing)
      expect(mail).to bcc_to([recipient.email])
      expect(I18n.locale).to eq(:en)
    end
  end

  shared_examples 'includes the usage percentage in both formats' do |method, percentage, expected|
    it 'shows the usage recorded when the notification was triggered', :aggregate_failures do
      mail = described_class.public_send(method, **mail_arguments, usage_percentage: percentage)

      expect(mail.html_part.body.decoded).to include(expected)
      expect(mail.text_part.body.decoded).to include(expected)
    end
  end

  describe '#notify_out_of_storage' do
    let(:mail_arguments) { { project: project, recipients: recipients } }

    it_behaves_like 'includes the usage percentage in both formats', :notify_out_of_storage, 125, '125%'
    it_behaves_like 'uses the recipient language', :notify_out_of_storage

    it 'says the project has reached its usage limit', :aggregate_failures do
      mail = described_class.notify_out_of_storage(project: project, recipients: recipients)

      expect(mail).to have_subject "Action required: #{project.name} is read-only"
      expect(mail).to bcc_to recipients
      expect(mail).to have_body_text("Project #{project_link} has reached its usage limit")
      expect(mail).to have_body_text(project_url(project))
      expect(mail).not_to have_body_text('Buy more storage')
    end
  end

  describe '#notify_limit_warning' do
    let(:mail_arguments) { { project: project, recipients: recipients } }

    it_behaves_like 'includes the usage percentage in both formats', :notify_limit_warning, 93.4, '93.4%'
    it_behaves_like 'uses the recipient language', :notify_limit_warning

    it 'says the project is about to reach its usage limit', :aggregate_failures do
      mail = described_class.notify_limit_warning(project: project, recipients: recipients)

      expect(mail).to have_subject "Action required: Unusually high storage usage on #{project.name}"
      expect(mail).to bcc_to recipients
      expect(mail).to have_body_text(
        "Project #{project_link} is about to reach its usage limit. Please check it"
      )
      expect(mail).to have_body_text(project_url(project))
      expect(mail).to have_body_text(
        'purchase additional storage to keep projects that exceed the included repository size from being restricted'
      )
      expect(mail).not_to have_body_text('Buy more storage')
    end
  end

  describe '#notify_group_out_of_storage' do
    let(:mail_arguments) { { namespace: group, recipients: recipients } }

    let(:group) { build_stubbed(:group, name: 'example-group') }
    let(:group_url) { usage_quotas_url(group, anchor: 'storage-quota-tab') }
    let(:group_link) { ActionController::Base.helpers.link_to(group.name, group_url) }

    it_behaves_like 'includes the usage percentage in both formats', :notify_group_out_of_storage, 100, '100%'
    it_behaves_like 'uses the recipient language', :notify_group_out_of_storage

    it 'says the group has used up its purchased storage', :aggregate_failures do
      mail = described_class.notify_group_out_of_storage(namespace: group, recipients: recipients)

      expect(mail).to have_subject "Action required: #{group.name} has used up its purchased storage"
      expect(mail).to bcc_to recipients
      expect(mail).to have_body_text("Group #{group_link} has used up its purchased storage")
      expect(mail).to have_body_text(group_url)
      expect(mail).not_to have_body_text('Buy more storage')
    end
  end

  describe '#notify_group_limit_warning' do
    let(:mail_arguments) { { namespace: group, recipients: recipients } }

    let(:group) { build_stubbed(:group, name: 'example-group') }
    let(:group_url) { usage_quotas_url(group, anchor: 'storage-quota-tab') }
    let(:group_link) { ActionController::Base.helpers.link_to(group.name, group_url) }

    it_behaves_like 'includes the usage percentage in both formats', :notify_group_limit_warning, 99.9, '99.9%'
    it_behaves_like 'uses the recipient language', :notify_group_limit_warning

    it 'says the group is about to use up its purchased storage', :aggregate_failures do
      mail = described_class.notify_group_limit_warning(namespace: group, recipients: recipients)

      expect(mail).to have_subject "Action required: Unusually high purchased storage usage for #{group.name}"
      expect(mail).to bcc_to recipients
      expect(mail).to have_body_text(
        "Group #{group_link} is about to use up its purchased storage. Please check it"
      )
      expect(mail).to have_body_text(group_url)
      expect(mail).to have_body_text(
        'purchase additional storage to keep projects that exceed the included repository size from being restricted'
      )
      expect(mail).not_to have_body_text('Buy more storage')
    end
  end
end
