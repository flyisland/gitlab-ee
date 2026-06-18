# frozen_string_literal: true

RSpec.shared_context 'for license_expression_checker' do
  # Report entries: [spdx_id, display_name, dependency_name]
  #
  # For expression entries the spdx_id and display_name are both set to the raw
  # expression string, because the scanner stores the expression as the license name.
  # The checker resolves individual SPDX IDs to display names after parsing.

  def report(expression, dependencies)
    [[expression, expression, dependencies]]
  end

  def violation(expression, *dependencies)
    { expression => dependencies }
  end

  let(:empty_report) { [] }
end
