# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Ligaai do
  let(:ligaai_integration) { create(:ligaai_integration) }

  describe '#create' do
    context 'when activated' do
      it 'is valid' do
        expect(ligaai_integration).to be_valid
        expect(ligaai_integration.category).to eq :issue_tracker
        expect(ligaai_integration.issue_tracker_path).to eq ligaai_integration.url
      end

      context 'when necessary attributes are empty' do
        let(:attributes) { %w[url project_key user_key api_token] }

        it 'fails to create' do
          attributes.each do |attribute|
            expect { create(:ligaai_integration, attribute => nil) }.to \
              raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end

    context 'when project is configured other issue tracker' do
      let(:other_integration) { create(:redmine_integration) }
      let(:ligaai_integration) { build(:ligaai_integration, project: other_integration.project) }

      context 'with manual change' do
        it 'is not valid' do
          expect(ligaai_integration).not_to be_valid(:manual_change)
        end
      end
    end
  end

  describe '#render?' do
    subject(:is_render) { ligaai_integration.render? }

    context 'when valid and activated' do
      it 'returns true' do
        expect(is_render).to be_truthy
      end
    end

    context 'when not activated' do
      before do
        ligaai_integration.update_attribute(:active, false)
      end

      it 'returns false' do
        expect(is_render).to be_falsey
      end
    end

    context 'when not valid' do
      before do
        ligaai_integration.url = nil
      end

      it 'returns false' do
        expect(is_render).to be_falsey
      end
    end
  end

  describe '#fields' do
    it 'returns custom fields' do
      expect(ligaai_integration.fields.pluck(:name).sort).to \
        eq %w[api_token api_url project_key url user_key]
    end
  end

  describe '#help' do
    it 'renders help information' do
      expect(ligaai_integration.help).not_to be_empty
    end
  end

  describe '#test' do
    let(:test_response) { { success: true } }

    before do
      allow_next_instance_of(Gitlab::Ligaai::Client) do |client|
        allow(client).to receive(:ping).and_return(test_response)
      end
    end

    it 'gets response from Gitlab::Ligaai::Client#ping' do
      expect(ligaai_integration.test).to eq(test_response)
    end
  end
end
