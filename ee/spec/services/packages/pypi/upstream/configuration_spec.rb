# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Pypi::Upstream::Configuration, feature_category: :package_registry do
  describe '.simple_url_for' do
    let(:base_url) { 'https://pypi.org/simple/' }

    where(:input, :expected) do
      [
        ['requests',          'https://pypi.org/simple/requests/'],
        ['Flask',             'https://pypi.org/simple/flask/'],
        ['zope.interface',    'https://pypi.org/simple/zope-interface/'],
        ['typing_extensions', 'https://pypi.org/simple/typing-extensions/']
      ]
    end

    with_them do
      it { expect(described_class.simple_url_for(input, base_url: base_url)).to eq(expected) }
    end

    it 'uses the provided base URL so JiHu / mirror overrides are respected' do
      expect(described_class.simple_url_for('requests', base_url: 'https://mirror.example/simple/'))
        .to eq('https://mirror.example/simple/requests/')
    end
  end
end
