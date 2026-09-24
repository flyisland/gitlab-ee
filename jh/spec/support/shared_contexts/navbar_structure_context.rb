# frozen_string_literal: true

RSpec.shared_context 'with dashboard navbar structure of jh' do
  let(:structure) do
    [
      {
        nav_item: _("Projects"),
        nav_sub_items: []
      },
      {
        nav_item: _("Groups"),
        nav_sub_items: []
      },
      {
        nav_item: _('Organizations'),
        nav_sub_items: []
      },
      {
        nav_item: _("Issues"),
        nav_sub_items: []
      },
      {
        nav_item: _("Merge requests"),
        nav_sub_items: [
          _('Assigned'),
          _('Review requests')
        ]
      },
      {
        nav_item: _("To-Do List"),
        nav_sub_items: []
      },
      {
        nav_item: _("Milestones"),
        nav_sub_items: []
      },
      {
        nav_item: _("Snippets"),
        nav_sub_items: []
      },
      {
        nav_item: _("Activity"),
        nav_sub_items: []
      },
      {
        nav_item: _("Performance Measurement"),
        nav_sub_items: []
      }
    ]
  end
end
