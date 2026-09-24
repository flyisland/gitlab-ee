# frozen_string_literal: true

module QA
  RSpec.describe 'JH Create', :smoke, feature_flag: { name: 'language_switcher' } do
    describe 'language switcher' do
      before do
        Flow::Login.sign_in
      end

      it 'compare the switched preferred_language value',
        testcase: "https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/65" do
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
        Page::Registration::LanguageSwitcher.perform(&:click_drop_down_box)
        Page::Registration::LanguageSwitcher.perform(&:switch_to_english)
        Page::Registration::LanguageSwitcher.perform do |sign_in|
          expect(sign_in).to have_sign_button_element("Sign in")
        end
      end
    end
  end
end
