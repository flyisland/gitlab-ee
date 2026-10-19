# frozen_string_literal: true

module SetDefaultPreferredLanguage
  def set_default_preferred_language_to_zh_cn
    stub_feature_flags(qa_enforce_locale_to_en: false)
    allow(::Gitlab::CurrentSettings).to receive(:default_preferred_language).and_return('zh_CN')
  end
end
