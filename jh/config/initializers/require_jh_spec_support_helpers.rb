# frozen_string_literal: true

::Gitlab::Application.configure do
  if Rails.env.test?
    # We want to use `prepend_mod` in test helper files.
    # Since helper files are not in the autoload path,
    # need to load them manually before EE helper module calls `prepend_mod`.
    Dir[Rails.root.join("jh/spec/support/helpers/jh/**/*.rb")].each { |f| require f }
  end
end
