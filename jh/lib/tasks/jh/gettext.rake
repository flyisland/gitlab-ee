# frozen_string_literal: true

require "gettext_i18n_rails/tasks"

JH_GETTEXT_NAMESPACE = 'JH|'

namespace :jh do
  namespace :gettext do
    desc "Regenerate JH pot/po files"
    task :regenerate do
      require Rails.root.join('jh/lib/gitlab/patch/tooling_gettext_extractor')
      require Rails.root.join('tooling/lib/tooling/gettext_extractor')

      # To not change the 'gettext:regenerate' from upstream by adding the prepend at here
      Tooling::GettextExtractor.prepend(::Gitlab::Patch::ToolingGettextExtractor)

      extractor = Tooling::GettextExtractor.new(
        glob_base: Rails.root.join('jh')
      )
      File.write(jh_pot_file_path, extractor.generate_pot)

      # "Rake.application.clear" does not reset task instance object
      # To pass rspec, we need to clear the meoization manually
      clear_memoization :@jh_pot
      clear_memoization :@jh_pos

      validate_new_added_msgids!

      jh_locales.each do |locale|
        update_po_file(locale)
      end
    end

    task :updated_check do
      begin
        Rake::Task['jh:gettext:regenerate'].invoke
      rescue RuntimeError
        raise <<~MSG

        For more details and solutions, please see MR: https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/913

        MSG
      end

      pot_diff = `git diff -- #{jh_po_file_path 'zh_CN'} | grep -E '^(\\+|-)msgid'`.strip

      # reset the locale folder for potential next tasks
      `git checkout -- jh/locale`

      if pot_diff.present?
        raise <<~MSG
        Changes in translated strings found, please update file `#{jh_pot_file_path}` by running:

          bin/rake jh:gettext:regenerate

        Then commit and push the resulting changes to `#{jh_pot_file_path}`.

        The diff was:

        #{pot_diff}
        MSG
      end
    end

    private

    def update_po_file(locale)
      output_po = GetText::PO.new(:msgid)

      # 1. Read existing jh/gitlab.po, only keep strings that exist in jh/gitlab.pot or gitlab/gitlab.pot
      # Two types of strings will be removed: Duo strings in msgid that have been deleted; strings starting with "JH|"
      jh_pos[locale].each do |msgid, entry|
        if jh_pot.key?(msgid) || gitlab_pot.key?(msgid)
          id = [entry.msgctxt, entry.msgid]
          output_po[*id] = entry

          next
        end

        if msgid.match?(/\bDuo\b/)
          puts "Remove unattached Duo po entry \"#{msgid}\" in locale :#{locale}."
        elsif msgid.start_with? JH_GETTEXT_NAMESPACE
          puts "Remove unattached JH only po entry \"#{msgid}\" in locale :#{locale}."
        else
          raise "Unattached po entry \"#{msgid}\" is found in locale :#{locale}."
        end
      end

      # 2. Iterate through jh/gitlab.pot, add strings starting with "JH|" to jh/gitlab.po
      jh_pot.each do |msgid, entry|
        next unless msgid.start_with? JH_GETTEXT_NAMESPACE
        next if jh_pos[locale].key? msgid

        id = [entry.msgctxt, entry.msgid]
        output_po[*id] = entry
      end

      File.write(jh_po_file_path(locale), output_po.to_s(max_line_width: -1))
    end

    def validate_new_added_msgids!
      new_keys = jh_msgids_without_prefix

      raise "Msgid without \"#{JH_GETTEXT_NAMESPACE}\" is found: #{new_keys.join(', ')}." unless new_keys.empty?
    end

    def jh_msgids_without_prefix
      jh_pot.keys.reject { |key| key.start_with? JH_GETTEXT_NAMESPACE } - gitlab_pot.keys
    end

    def jh_locales
      %w[en zh_CN zh_TW]
    end

    def jh_pot
      @jh_pot ||= po_parse(jh_pot_file_path)
    end

    def jh_pos
      @jh_pos ||= jh_locales.index_with do |locale|
        po_parse(jh_po_file_path(locale))
      end
    end

    def gitlab_pot
      @gitlab_pot ||= po_parse(gitlab_pot_file_path)
    end

    def po_parse(file)
      parser = GetText::POParser.new
      parser.ignore_fuzzy = true

      parser.parse_file(file, GetText::PO.new).index_by(&:msgid)
    end

    def jh_locale_path
      Rails.root.join('jh/locale')
    end

    def gitlab_pot_file_path
      Rails.root.join('locale/gitlab.pot')
    end

    def jh_pot_file_path
      File.join(jh_locale_path, 'gitlab.pot')
    end

    def jh_po_file_path(locale)
      File.join(jh_locale_path, locale, 'gitlab.po')
    end

    def clear_memoization(name)
      remove_instance_variable(name) if instance_variable_defined?(name)
    end
  end
end
