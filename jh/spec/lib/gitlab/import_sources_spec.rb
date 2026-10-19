# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportSources do
  describe '.values' do
    it 'returns an array' do
      expected =
        %w[
          github
          bitbucket
          bitbucket_server
          fogbugz
          git
          gitlab_project
          gitea
          manifest
          gitlab_built_in_project_template
          gitee
        ]

      expect(described_class.values).to eq(expected)
    end
  end

  describe '.importable_project_types', feature_category: :importers do
    it 'returns all importer types except project template importers' do
      expect(described_class.importable_project_types).to eq(
        %w[github bitbucket bitbucket_server fogbugz git gitlab_project gitea manifest gitee]
      )
    end
  end

  describe '.has_importer?' do
    it 'returns true when has import source has importer' do
      with_importer =
        %w[
          github
          bitbucket
          bitbucket_server
          fogbugz
          gitlab_project
          gitea
        ]

      without_importer = %w[git manifest doesnotexist]

      with_importer.each do |import_source|
        expect(described_class.has_importer?(import_source)).to be(true)
      end

      without_importer.each do |import_source|
        expect(described_class.has_importer?(import_source)).to be(false)
      end
    end
  end

  describe '.import_table' do
    it 'includes specific JH imports types when the license supports them' do
      expect(described_class.jh_import_table).not_to be_empty
      expect(described_class.import_table).to include(*described_class.jh_import_table)
    end
  end
end
