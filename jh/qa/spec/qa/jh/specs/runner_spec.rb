# frozen_string_literal: true

RSpec.describe QA::JH::Specs::Runner do
  subject(:rspec_paths) { runner.method(:rspec_paths).call }

  let(:runner) { QA::Specs::Runner.new }
  let(:rspec_retried) { false }

  before do
    allow(QA::Runtime::Env).to receive(:rspec_retried?).and_return(rspec_retried)
  end

  it "is prepended to the upstream runner" do
    expect(QA::Specs::Runner).to be < described_class
  end

  it "uses the JH feature spec directory" do
    expect(Pathname.new(described_class::JH_DEFAULT_TEST_PATH)).to be_directory
  end

  context "when the test run is not a retry" do
    it "keeps the upstream spec path" do
      expect(rspec_paths).to eq([QA::Specs::Runner::DEFAULT_TEST_PATH])
    end
  end

  context "when the test run is a retry" do
    let(:rspec_retried) { true }

    it "includes the upstream and JH spec paths" do
      expect(rspec_paths).to eq([
        QA::Specs::Runner::DEFAULT_TEST_PATH,
        described_class::JH_DEFAULT_TEST_PATH
      ])
    end

    context "when the JH spec path is already included" do
      before do
        allow(runner).to receive(:custom_spec_paths)
          .and_return([described_class::JH_DEFAULT_TEST_PATH])
      end

      it "does not duplicate the JH spec path" do
        expect(rspec_paths).to eq([described_class::JH_DEFAULT_TEST_PATH])
      end
    end
  end
end
