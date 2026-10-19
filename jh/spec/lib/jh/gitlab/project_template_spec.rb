# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ProjectTemplate do
  let(:jh_templates) { %w[dongtai_iast] }

  describe '#archive_path' do
    context 'when global template' do
      let(:global_template) { described_class.all.find { |template| jh_templates.exclude?(template.name) } }

      it 'start with `vendor/project_templates`' do
        expected = Rails.root.join('vendor/project_templates').join(global_template.archive_filename)
        expect(global_template.archive_path).to eq(expected)
      end
    end

    context 'when JiHu-only template' do
      let(:jh_template) { described_class.all.find { |template| jh_templates.include?(template.name) } }

      it 'start with `jh/vendor/project_templates`' do
        expected = Rails.root.join('jh/vendor/project_templates').join(jh_template.archive_filename)
        expect(jh_template.archive_path).to eq(expected)
      end
    end
  end

  describe '.localized_templates_table' do
    it 'use the jh preview' do
      expect(described_class.localized_templates_table.map(&:preview)).to all(
        start_with(JH::Gitlab::ProjectTemplate::JH_PROJECT_TEMPLATE_GROUP)
      )
    end
  end

  describe '.localized_ee_templates_table' do
    it 'use the jh preview' do
      expect(described_class.localized_ee_templates_table.map(&:preview)).to all(
        start_with(JH::Gitlab::ProjectTemplate::JH_PROJECT_TEMPLATE_GROUP)
      )
    end
  end
end
