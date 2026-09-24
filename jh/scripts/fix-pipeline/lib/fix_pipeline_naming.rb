# frozen_string_literal: true

# Standalone helper: must work under plain `bundle exec ruby` (no Rails/ActiveSupport).
require 'tzinfo'

module FixPipelineNaming
  DEFAULT_TIMEZONE = 'Asia/Shanghai'
  BRANCH_PREFIX = 'fix-pipeline'
  BRANCH_SUFFIX = 'auto'

  module_function

  def timezone
    ENV.fetch('FIX_PIPELINE_TIMEZONE', DEFAULT_TIMEZONE)
  end

  def date_today
    explicit = ENV['FIX_PIPELINE_DATE'].to_s.strip
    return explicit if explicit.match?(/\A\d{8}\z/)

    TZInfo::Timezone.get(timezone).now.strftime('%Y%m%d')
  end

  def branch_name
    explicit = ENV['MR_SOURCE_BRANCH'].to_s.strip
    return explicit unless explicit.empty?

    "#{BRANCH_PREFIX}-#{date_today}-#{BRANCH_SUFFIX}"
  end

  def mr_title
    explicit = ENV['MR_TITLE'].to_s.strip
    return explicit unless explicit.empty?

    "Fix pre-main-jh pipeline #{date_today} Auto"
  end
end
