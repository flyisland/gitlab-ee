# frozen_string_literal: true

ENV['MT_NO_PLUGINS'] = '1'

require 'minitest/autorun'
require_relative '../lib/fix_pipeline_naming'

module FixPipeline
  class FixPipelineNamingTest < Minitest::Test
    def setup
      @original_env = ENV.to_h.slice(
        'FIX_PIPELINE_DATE',
        'FIX_PIPELINE_TIMEZONE',
        'MR_SOURCE_BRANCH',
        'MR_TITLE'
      )
      %w[FIX_PIPELINE_DATE FIX_PIPELINE_TIMEZONE MR_SOURCE_BRANCH MR_TITLE].each { |key| ENV.delete(key) }
    end

    def teardown
      ENV.replace(@original_env)
    end

    def test_branch_name_uses_date_today
      ENV['FIX_PIPELINE_DATE'] = '20260811'

      assert_equal 'fix-pipeline-20260811-auto', FixPipelineNaming.branch_name
    end

    def test_branch_name_honors_explicit_override
      ENV['FIX_PIPELINE_DATE'] = '20260811'
      ENV['MR_SOURCE_BRANCH'] = 'custom-branch'

      assert_equal 'custom-branch', FixPipelineNaming.branch_name
    end

    def test_mr_title_uses_date_today
      ENV['FIX_PIPELINE_DATE'] = '20260811'

      assert_equal 'Fix pre-main-jh pipeline 20260811 Auto', FixPipelineNaming.mr_title
    end
  end
end
