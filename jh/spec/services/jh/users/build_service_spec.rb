# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BuildService do
  using RSpec::Parameterized::TableSyntax

  describe '#execute' do
    let(:current_user) { nil }
    let(:preferred_language) { nil }
    let(:params) { build_stubbed(:user).slice(:first_name, :last_name, :username, :email, :password) }
    let(:service) { described_class.new(current_user, params) }

    subject(:user) { service.execute }

    context 'when signup' do
      before do
        params.merge!({ first_name: first_name, last_name: last_name, preferred_language: preferred_language })
      end

      context 'with zh locales' do
        where(:first_name, :last_name, :expected_name) do
          '三丰' | '张' | '张 三丰'
          '亮' | '诸葛' | '诸葛 亮'
          'Siu-long' | '李' | '李 Siu-long'
          'Ang' | 'Lee' | 'Lee Ang'
        end

        with_them do
          let(:preferred_language) { 'zh_CN' }

          it 'fills name with fallback_name' do
            expect(user.name).to eq(expected_name)
          end
        end
      end

      context 'with not zh locales' do
        where(:first_name, :last_name, :expected_name) do
          'Siu-long' | '李' | 'Siu-long 李'
          'Ang' | 'Lee' | 'Ang Lee'
        end

        with_them do
          let(:preferred_language) { 'en' }

          it 'fills name with fallback_name' do
            expect(user.name).to eq(expected_name)
          end
        end
      end
    end
  end
end
