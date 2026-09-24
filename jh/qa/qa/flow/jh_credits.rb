# frozen_string_literal: true

module QA
  module Flow
    module JhCredits
      extend self

      def consume_with_chat(prompt)
        QA::EE::Page::Component::DuoChat.perform do |duo_chat|
          duo_chat.open_duo_chat unless duo_chat.duo_chat_open?
          duo_chat.clear_chat_history
          duo_chat.send_duo_chat_prompt(prompt)
        end

        QA::Page::Component::DuoAgentPlatform.perform(&:wait_for_chat_response_complete)
        QA::EE::Page::Component::DuoChat.perform(&:response)
      end

      def sync_spend_credits(max_duration: 120)
        api = QA::ThirdPartyPage::Customerdot::API.new

        QA::Support::Retrier.retry_until(
          max_duration: max_duration,
          sleep_interval: 5,
          retry_on_exception: true,
          message: 'Wait for CustomerDot credits spend sync'
        ) do
          result = api.sync_spend_credits
          result.dig('message', 'consume_count').to_i > 0
        end
      end

      def wait_for_consumed_credits(group, max_duration: 120, &condition)
        group.visit!
        QA::Page::Group::Settings::GitlabCredits.perform(&:go_to_gitlab_credits)
        QA::Page::Group::Settings::GitlabCredits.perform do |gitlab_credits|
          gitlab_credits.wait_for_total_usage(max_duration: max_duration, &condition)
        end
      end
    end
  end
end
