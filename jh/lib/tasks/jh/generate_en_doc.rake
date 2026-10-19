# frozen_string_literal: true

namespace :jh do
  namespace :doc do
    desc "generate jh en doc"
    task :generate_en_doc do
      rules_path = Rails.root.join('jh/config/doc_scan_rules.yml')
      doc_dir = Rails.root.join("doc")
      dest_dir = Rails.root.join("jh/doc-en")

      dest_dir.exist? || FileUtils.makedirs(dest_dir)

      rules = YAML.load_file(rules_path)
      excluded_files = rules["excluded_files"] || []
      delete_rules = rules["delete_rules"] || []
      replace_rules = rules["replace_rules"] || []

      paths = Find.find(doc_dir).to_a
      paths.each do |path|
        new_path = path.to_s.gsub(doc_dir.to_s, dest_dir.to_s)
        next unless FileTest.file?(path)

        path = path.to_s
        path_suffix = path[path.index("/doc"), path.length - path.index("/doc")]
        next if excluded_files.include?(path_suffix)

        dir_name = Pathname(new_path).dirname
        dir_name.exist? || FileUtils.makedirs(dir_name)

        if File.extname(path) == ".md"

          file_data = File.read(path)

          delete_rules.each do |key|
            file_data = file_data.gsub(key, "")
          end
          replace_rules.each do |rule|
            file_data = file_data.gsub(rule["from"], rule["to"])
          end

          File.write(new_path, file_data, mode: "w")
        else
          FileUtils.copy(path, new_path)
        end
      end
    end
  end
end
