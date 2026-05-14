# frozen_string_literal: true

RSpec.shared_examples 'tool_approval_for_session_availability setter' do
  describe '#tool_approval_for_session_availability=' do
    using RSpec::Parameterized::TableSyntax

    where(:tool_approval_for_session_availability, :tool_approval_for_session_enabled_expectation,
      :lock_tool_approval_for_session_enabled_expectation) do
      true  | true  | false
      false | false | true
    end

    with_them do
      before do
        setting.tool_approval_for_session_availability = tool_approval_for_session_availability
      end

      it 'returns the expected response' do
        expect(setting.tool_approval_for_session_enabled).to be tool_approval_for_session_enabled_expectation
        expect(setting.lock_tool_approval_for_session_enabled)
          .to be lock_tool_approval_for_session_enabled_expectation
      end
    end
  end
end
