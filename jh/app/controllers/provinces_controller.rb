# frozen_string_literal: true

class ProvincesController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::ApiRendering
  include ActionController::Renderers

  use_renderers :json

  def index
    provinces = China.provinces_for_select

    render json: provinces, status: (provinces ? :ok : :not_found)
  end
end
