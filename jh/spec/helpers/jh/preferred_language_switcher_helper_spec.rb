# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PreferredLanguageSwitcherHelper do
  include StubLanguagesTranslationPercentage

  describe '#ordered_selectable_locales' do
    it 'return results include Simplified Chinese' do
      locales = helper.ordered_selectable_locales
      expect(locales.map { |locale| locale[:value] }).to include('zh_CN')
    end
  end
end
