# frozen_string_literal: true

module Cd
  class ApplicationPolicy < ::BasePolicy
    delegate { @subject.group || @subject.organization }
  end
end
