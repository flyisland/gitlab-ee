# frozen_string_literal: true

# Ai::Catalog::FoundationalFlow is a fixed-items model: every flow is one process-wide
# instance, and `catalog_item` is strong-memoized on it. An example that stubs
# `Ai::Catalog::Item.with_foundational_flow_reference`, or that creates the item inside its
# own transaction, leaves the flow pointing at a record no later example can see, and the
# flow execution authorizer then 403s requests that expected the ungoverned path.
#
# This reads `storage` rather than `find_each`/`all`: those call `load_items!` when the
# cache is empty, which would populate it from the unstubbed `fixed_items` before an
# example's own `before` gets to stub them.
RSpec.configure do |config|
  config.after do
    ::Ai::Catalog::FoundationalFlow.storage.each { |flow| flow&.clear_memoization(:catalog_item) }
  end
end
