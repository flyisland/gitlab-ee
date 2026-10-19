# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    module Settings
      SETTINGS = {
        orbit_auto_index_root_namespace: {
          type: :boolean,
          default: false,
          label: -> { s_('Orbit|Index root namespaces automatically') }
        },
        orbit_dap_enabled_by_default: {
          type: :boolean,
          default: true,
          label: -> { s_('Orbit|Turn on Orbit in GitLab Duo') }
        }
      }.freeze

      class << self
        def all_settings
          SETTINGS
        end
      end
    end
  end
end
