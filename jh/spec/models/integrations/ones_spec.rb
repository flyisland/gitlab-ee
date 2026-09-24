# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Ones do
  include OnesClientHelper

  let(:ones_integration) { create(:ones_integration) }

  describe '#create' do
    context 'when activated' do
      it 'is valid' do
        expect(ones_integration).to be_valid
        expect(ones_integration.category).to eq :issue_tracker
        expect(ones_integration.issue_tracker_path).to eq \
          "#{ones_integration.url}/project/#/team/#{ones_integration.namespace}/project/#{ones_integration.project_key}"
      end

      context 'when necessary attributes are empty' do
        let(:attributes) { %w[url namespace project_key user_key api_token] }

        it 'fails to create' do
          attributes.each do |attribute|
            expect { create(:ones_integration, attribute => nil) }.to \
              raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end

    context 'when project is configured other issue tracker' do
      let(:other_integration) { create(:redmine_integration) }
      let(:ones_integration) { build(:ones_integration, project: other_integration.project) }

      context 'with manual change' do
        it 'is not valid' do
          expect(ones_integration).not_to be_valid(:manual_change)
        end
      end
    end
  end

  describe '#render?' do
    subject(:is_render) { ones_integration.render? }

    context 'when valid and activated' do
      it 'returns true' do
        expect(is_render).to be_truthy
      end
    end

    context 'when not activated' do
      before do
        ones_integration.update_attribute(:active, false)
      end

      it 'returns false' do
        expect(is_render).to be_falsey
      end
    end

    context 'when not valid' do
      before do
        ones_integration.url = nil
      end

      it 'returns false' do
        expect(is_render).to be_falsey
      end
    end
  end

  describe '#fields' do
    it 'returns custom fields' do
      expect(ones_integration.fields.pluck(:name).sort).to \
        eq %w[api_token api_url namespace project_key url user_key]
    end
  end

  describe '#help' do
    it 'renders help information' do
      expect(ones_integration.help).to include '/help/user/project/integrations/ones'
    end
  end

  describe '#test' do
    let(:graphql_url) { ones_url "team/#{ones_integration.namespace}/items/graphql" }
    let(:success) {} # rubocop:disable Lint/EmptyBlock

    subject(:test) { ones_integration.test }

    before do
      mock_fetch_project(url: graphql_url, project_uuid: ones_integration.project_key, success: success)
    end

    context 'with correct arguments' do
      let(:success) { true }

      it 'returns success' do
        expect(test).to include(success: success)
      end
    end

    context 'without correct arguments' do
      let(:success) { false }

      it 'returns error message' do
        expect(test).to include(success: success)
      end
    end
  end

  describe '#reference_pattern' do
    it 'can response to reference_pattern' do
      expect { described_class.new.reference_pattern }.not_to raise_error
    end
  end
end
