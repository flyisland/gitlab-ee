# frozen_string_literal: true

::License.send(:remove_const, :EE_ALL_PLANS) # rubocop:disable GitlabSecurity/PublicSend
module JH
  module License
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    TEAM_PLAN = 'team'

    EE_ALL_PLANS = [TEAM_PLAN, ::License::STARTER_PLAN, ::License::PREMIUM_PLAN, ::License::ULTIMATE_PLAN].freeze

    def paid?
      [TEAM_PLAN, ::License::STARTER_PLAN, ::License::PREMIUM_PLAN, ::License::ULTIMATE_PLAN].include?(plan)
    end

    private

    # rubocop:disable Style/RedundantSelf -- need it here
    override :add_limit_error
    def add_limit_error(user_count:, current_period: true, type: :invalid)
      super

      regxp = /about\.gitlab\.com/
      self.errors[:base].each do |msg|
        if regxp.match?(msg)
          self.errors.delete(:base, type)
          self.errors.add(:base, type, message: msg.gsub(regxp, 'gitlab.cn'))
        end
      end
    end
    # rubocop:enable Style/RedundantSelf
  end
end
