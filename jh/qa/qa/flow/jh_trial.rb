# frozen_string_literal: true

module QA
  module Flow
    module JhTrial
      extend self

      def start_trial(group_path = nil, skip_select: false)
        unless skip_select || group_path.nil?
          ::QA::ThirdPartyPage::Trials::Select.perform do |select|
            select.select_group(group_path)
          end
        end

        ::QA::ThirdPartyPage::Trials::New.perform do |new|
          new.fill_last_name('QA') if new.has_last_name_field?
          new.fill_company_name('Jihu QA')
          new.select_default_country
          new.fill_telephone('13800000000')
          new.activate_my_trial
        end
      end

      def verify_trial_success
        Support::Retrier.retry_until(max_attempts: 3, reload_page: true, sleep_interval: 5) do
          Page::Group::Settings::Billing.perform do |billing|
            billing.has_text?("Your group is on a trial of GitLab Ultimate")
          end
        end
      end
    end
  end
end
