# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ProjectScanWorker do
  let_it_be(:project) { create(:project, :repository) }

  describe "perform" do
    subject { described_class.new.perform(project.id, { ref: "main" }) }

    it "call ContentValidation::ProjectScanService" do
      expect(ContentValidation::ProjectScanService).to receive(:new).with(project, { ref: "main" }).and_call_original
      subject
    end
  end
end
