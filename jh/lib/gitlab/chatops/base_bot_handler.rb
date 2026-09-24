# frozen_string_literal: true

module Gitlab
  module Chatops
    class BaseBotHandler
      include LocateProject

      class Error < StandardError
        attr_reader :response

        def initialize(message = nil, response = nil)
          super(message)
          @response = response
        end
      end

      UrlVerificationError = Class.new(Error)
      RepeatEventError = Class.new(Error)
      MessageValidationError = Class.new(Error)

      attr_reader :params, :headers

      def initialize(params, headers)
        @params = params
        @headers = headers
      end

      def execute
        process_url_verification!
        process_repeat_event!
        validate_data!
        response = formatter.response_body(reply_message)

        process_response(response)
      rescue Error => e
        Gitlab::AppLogger.info "API Responsed by: `#{e.class.name}`"

        case e
        when UrlVerificationError
          e.response
        when MessageValidationError
          response = formatter.response_text_body(e.message)
          process_response(response)
        end
      end

      private

      def process_url_verification!
        raise NotImplementedError
      end

      def process_repeat_event!
        raise NotImplementedError
      end

      def validate_data!
        validate_license!
        validate_non_saas!
        validate_feature_flag!
        validate_message!
        validate_setting!
        validate_integration!
        validate_chat_name!
      end

      def validate_license!
        return if ::License.feature_available?(feature_name)

        message = format(
          s_("JH|Chatops|%{platform_name} bot is deactivated. Please upgrade your JiHu GitLab to Premium Plan"),
          platform_name: platform_name
        )
        raise MessageValidationError, message
      end

      def validate_non_saas!
        return unless ::Gitlab.com?

        message = format(
          s_("JH|Chatops|%{platform_name} Integration for Saas is coming soon."),
          platform_name: platform_name
        )
        raise MessageValidationError, message
      end

      def validate_feature_flag!
        return unless have_feature_flag?
        return if ::Feature.enabled?(feature_name)

        message = format(
          s_('JH|Chatops|Please enable the "%{feature_name}" feature flag in JiHu GitLab.'),
          feature_name: feature_name
        )
        raise MessageValidationError, message
      end

      def validate_message!
        return if valid_message?

        message = format(
          s_("JH|Chatops|Message verification failed. Please check your settings of " \
            "%{platform_name} Integration in JiHu GitLab."),
          platform_name: platform_name
        )
        raise MessageValidationError, message
      end

      def validate_setting!
        return if setting_enabled?

        message = format(
          s_("JH|Chatops|Please contact your administrator to enable %{integration} in Admin - Settings - General"),
          integration: "#{platform_name.capitalize} Integration"
        )

        raise MessageValidationError, message
      end

      def validate_integration!
        return if integration&.activated?

        message = format(
          s_("JH|Chatops|Please contact your administrator to enable %{integration} in Admin - Settings - Integration"),
          integration: "#{platform_name.capitalize} Integration"
        )

        raise MessageValidationError, message
      end

      def validate_chat_name!
        return if chat_name&.user

        send_bind_link_message
        message = s_("JH|Chatops|You need to connect your JiHu GitLab account before performing bot commands.")

        raise MessageValidationError, message
      end

      def reply_message
        return ::Gitlab::ChatopsCommands::Presenters::Helper.help(group_message?) if help?

        project_path, command = parse_command_text(command_message)
        project = locate_project(project_path)

        return ::Gitlab::ChatopsCommands::Presenters::Helper.not_active_user unless chat_name.user.active?
        return ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_project(project_path) unless project

        command_data = get_command_data(command)
        ::Gitlab::ChatopsCommands::Command.new(project, chat_name, command_data).execute
      end

      def help?
        command_message == "help" || command_message.blank?
      end

      # 'help' => [nil, 'help']
      # 'group/project issue new some title' => ['group/project', 'issue new some title']
      def parse_command_text(text)
        raise ArgumentError, "Blank `text`" if text.blank?

        fragments = text.strip.split(/\s/, 2)
        fragments.size == 1 ? [nil, fragments.first] : fragments
      end

      def get_command_data(command)
        params.merge(
          text: command,
          original_text: command_message,
          group_message: group_message?,
          responder_channel: responder[:channel],
          responder_response_url: responder[:response_url]
        )
      end

      # Dingtalk Bot support reply message through the message response,
      # so we need not call api to reply after receive a message.
      def process_response(response)
        response
      end

      def formatter
        @formatter ||= formatter_class.new(data: params, headers: headers)
      end

      def have_feature_flag?
        false
      end

      def valid_message?
        raise NotImplementedError
      end

      def send_bind_link_message
        raise NotImplementedError
      end

      def responder
        raise NotImplementedError
      end

      def command_message
        raise NotImplementedError
      end

      def chat_name
        raise NotImplementedError
      end

      def integration
        raise NotImplementedError
      end

      def setting_enabled?
        raise NotImplementedError
      end

      def group_message?
        raise NotImplementedError
      end

      def formatter_class
        raise NotImplementedError
      end

      def feature_name
        raise NotImplementedError
      end

      def platform_name
        raise NotImplementedError
      end
    end
  end
end
