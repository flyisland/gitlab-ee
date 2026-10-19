# frozen_string_literal: true

# Grape auto-registers each validator via an `inherited` hook the moment its
# class is loaded, deriving the short name from the class name. We only need to
# ensure every custom validator class is loaded; referencing the constant makes
# Zeitwerk load it (autoload paths are not eager-loaded in development/test).
# `Grape::Validations.register_validator` is removed in Grape 3.x, so we rely on
# auto-registration instead of calling it.
[
  ::API::Validations::Validators::Phone
].each(&:name)
