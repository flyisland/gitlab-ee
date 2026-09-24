# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseTemplateFinder do
  let(:from_licensee) do
    Licensee::License.all({ hidden: true, pseudo: false }).map(&:key) - described_class::EXCLUDED_LICENSES
  end

  describe '#execute' do
    subject(:result) { described_class.new(nil, params).execute }

    let(:categories) { categorised_licenses.keys }
    let(:categorised_licenses) { result.group_by(&:category) }

    context 'when popular is nil' do
      let(:params) { { popular: nil } }

      it 'returns all licenses known by the Licensee gem' do
        # Add Mulan-PSL. See gitlab-cn/gitlab#1224
        from_licensee.append("mulanpsl-2.0")
        expect(result.map(&:key)).to match_array(from_licensee)
      end
    end
  end

  describe '#template_names' do
    let(:params) { {} }
    let(:categories) { categorised_licenses.keys }
    let(:categorised_licenses) { template_names }

    subject(:template_names) { described_class.new(nil, params).template_names }

    context 'when popular is nil' do
      let(:params) { { popular: nil } }

      it 'returns all licenses known by the Licensee gem' do
        # Add Mulan-PSL. See gitlab-cn/gitlab#1224
        from_licensee.append("mulanpsl-2.0")

        expect(template_names.values.flatten.map { |x| x[:key] }).to match_array(from_licensee)
      end
    end
  end
end
