# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Service, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }

  describe 'associations' do
    it { is_expected.to belong_to(:application).required }
    it { is_expected.to have_one(:artifact_source) }
  end

  describe 'validations' do
    subject { build(:cd_service, application: application) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    describe 'name format' do
      it { is_expected.to allow_value('my-service').for(:name) }
      it { is_expected.to allow_value('my_service').for(:name) }
      it { is_expected.to allow_value('MyService').for(:name) }
      it { is_expected.to allow_value('service1').for(:name) }
      it { is_expected.to allow_value('1service').for(:name) }
      it { is_expected.not_to allow_value('-service').for(:name) }
      it { is_expected.not_to allow_value('service-').for(:name) }
      it { is_expected.not_to allow_value('my service').for(:name) }
      it { is_expected.not_to allow_value('service/name').for(:name) }
      it { is_expected.not_to allow_value('service.name').for(:name) }
      it { is_expected.not_to allow_value('service!').for(:name) }
    end

    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    it 'enforces uniqueness of name scoped to application_id at the database level' do
      create(:cd_service, application: application, name: 'checkout')

      expect { create(:cd_service, application: application, name: 'checkout') }
        .to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end
  end

  describe 'sharding key' do
    subject { build(:cd_service, application: application) }

    it { is_expected.to populate_sharding_key(:organization_id).with(application.organization_id) }
  end
end
