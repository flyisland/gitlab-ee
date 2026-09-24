# frozen_string_literal: true

Rails.application.configure do
  insert_assets_path = ->(path) {
    config = Rails.application.config
    insert_index = config.assets.paths.index { |path| path == "#{config.root}/node_modules/@gitlab/svgs/dist" }
    config.assets.paths.insert(insert_index + 1, path)
  }

  insert_assets_path.call("#{config.root}/node_modules/@jihu-fe/svgs/dist")
end
