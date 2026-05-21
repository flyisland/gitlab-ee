# frozen_string_literal: true

RSpec.shared_examples 'tracks namespace creation experiments' do
  context 'with experiments' do
    let(:trial_first_registration_experiment) { instance_double(ApplicationExperiment) }

    it 'tracks experiment assignment' do
      expect_next_instance_of(described_class) do |service|
        expect(service).to receive(:experiment).with(:trial_first_registration,
          actor: user, only_assigned: true).and_return(trial_first_registration_experiment)
      end

      expect(trial_first_registration_experiment).to receive(:track).with(:assignment,
        namespace: an_instance_of(Group))

      expect(execute).to be_success
    end
  end
end
