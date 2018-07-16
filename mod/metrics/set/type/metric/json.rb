format :json do
  NESTED_FIELD_CODENAMES =
    %i[metric_type about methodology value_type value_options
       report_type research_policy project unit
       range currency hybrid question score].freeze

  def item_cards
    NESTED_FIELD_CODENAMES.map do |codename|
      card.field codename
    end.compact
  end

  view :fields do
    item_cards.each_with_object({}) do |i_card, h|
      h[i_card.name.tag] = nest i_card, view: :atom
    end
  end

  view :items do
    []
  end

  view :atom do
    super().merge records_url: path(mark: card.field(:record), format: :json)
  end

  view :molecule do
    super().merge fields: _render_fields
  end
end