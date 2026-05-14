# frozen_string_literal: true

RSpec.shared_examples 'tracks namespace creation experiments' do
  context 'with experiments' do
    context 'with experiment premium_message_experiment' do
      let(:premium_message_experiment) { instance_double(ApplicationExperiment) }
      let(:trial_first_registration_experiment) { instance_double(ApplicationExperiment) }

      it 'tracks experiment assignment' do
        allow_next_instance_of(::Projects::CreateService) do |service|
          allow(service).to receive(:after_create_actions)
        end

        allow(premium_message_experiment).to receive(:exclude!)

        expect_next_instance_of(described_class) do |service|
          expect(service).to receive(:experiment).with(:trial_first_registration,
            actor: user, only_assigned: true).and_return(trial_first_registration_experiment)
          expect(service).to receive(:experiment).with(:premium_message_during_trial,
            namespace: an_instance_of(Group)).and_yield(premium_message_experiment)
        end

        expect(trial_first_registration_experiment).to receive(:track).with(:assignment,
          namespace: an_instance_of(Group))

        expect(execute).to be_success
      end
    end
  end
end
