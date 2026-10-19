# frozen_string_literal: true

namespace :gettext do
  desc "Compile locale files for Upstream and Jihu"
  task :compile do
    FileUtils.touch(pot_file_path)

    command = [
      "node", "./jh/scripts/frontend/po_to_json.js",
      "--locale-root", Rails.root.join('locale').to_s,
      "--output-dir", Rails.root.join('app/assets/javascripts/locale').to_s
    ]

    abort Rainbow('Error: Unable to convert gettext files to js.').red unless Kernel.system(*command)
    Rake::Task["gettext:compile"].clear_actions
  end

  def locale_path
    @locale_path ||= Rails.root.join('locale')
  end

  def pot_file_path
    @pot_file_path ||= File.join(locale_path, 'gitlab.pot')
  end
end
