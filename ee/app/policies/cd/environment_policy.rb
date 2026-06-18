# frozen_string_literal: true

module Cd
  class EnvironmentPolicy < ::BasePolicy
    delegate { @subject.group || @subject.organization }
  end
end
