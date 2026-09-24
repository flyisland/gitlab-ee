# frozen_string_literal: true

module VisitorIdCode
  private

  def visitor_id_code
    request.cookies[Gitlab::Application.config.session_options[:key]]
  end
end
