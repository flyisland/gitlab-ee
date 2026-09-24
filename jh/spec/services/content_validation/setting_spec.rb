# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::Setting do
  let(:public_container) { create(:project, :public) }
  let(:private_container) { create(:project, :private) }

  before do
    allow(Gitlab).to receive(:com?).and_return(true)
    stub_application_setting(content_validation_endpoint_enabled: true)
  end

  describe ".block_enabled?" do
    context "with public container" do
      it "return true" do
        expect(described_class.block_enabled?(public_container)).to be(true)
      end
    end

    context "with private project" do
      it "return false" do
        expect(described_class.block_enabled?(private_container)).to be(false)
      end
    end
  end

  describe ".check_enabled?" do
    context "with public container" do
      it "return true" do
        expect(described_class.check_enabled?(public_container)).to be(true)
      end
    end

    context "with private project" do
      it "return false" do
        expect(described_class.check_enabled?(private_container)).to be(false)
      end
    end
  end
end
