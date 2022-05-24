format :html do
  before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_header do
    [super(), (render_filtered_results_chart if show_chart?)].compact
  end

  view :filtered_results_stats, cache: :never, template: :haml
  view :filtered_results_chart, cache: :never, template: :haml

  view :core, cache: :never do
    if total_results.positive?
      haml :core
    else
      haml :no_results
    end
  end

  view :table, cache: :never do
    wrap true, "data-details-config": details_config.to_json do
      wikirate_table self, cell_views,
                     header: header_cells,
                     td: { classes: %w[header data] },
                     tr: { method: :tr_attribs },
                     table: { class: table_type }
    end
  end

  def details_config
    { view: details_view, layout: details_layout }
  end

  def details_layout
    :sidebar
  end

  def show_company_count?
    true
  end

  def show_metric_count?
    true
  end

  def export_formats
    %i[csv json]
  end

  def table_type
    :metric_answer
  end

  def tr_attribs row_card
    return {} unless row_card.known?

    { class: "details-toggle", "data-details-mark": row_card.name.url_key }
  end

  def extra_paging_path_args
    @extra_paging_path_args ||= super.merge sort_by: sort_by, sort_dir: sort_dir
  end
end