include_set Abstract::TwoColumnLayout
include_set Abstract::Tabs

TAB_MAP = {
  company:    [:building,   :num_companies,    "Companies"],
  metric:     ["bar-chart", :num_metrics,      "Metrics"],
  year:       [:calendar,   :num_years,        "Years"],
  subproject: [:flask,      :num_subprojects,  "Subprojects"]
}.freeze

format :html do
  view :open_content do |args|
    bs_layout container: false, fluid: true, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _render_content_left_col, args[:left_class]
        column _render_content_right_col, args[:right_class]
      end
    end
  end

  def default_content_formgroup_args _args
    voo.edit_structure = [
      :image,
      :wikirate_status,
      :parent,
      :organizer,
      :wikirate_topic,
      :description,
      :year,
      :metric,
      :wikirate_company
    ]
  end

  def header_right
    wrap_with :div, class: "header-right" do
      [
        wrap_with(:h3, _render_title, class: "project-title"),
        field_nest(:wikirate_status, view: :labeled),
        (field_nest(:parent, view: :labeled) if card.parent.present?)
      ].compact
    end
  end

  view :data do
    wrap_with :div, class: "project-details" do
      project_details
    end
  end

  view :content_right_col do
    wrap_with :div, class: "progress-column" do
      [overall_progress_box, _render_tabs, _render_export_links]
    end
  end

  def active_tabs
    [:company, :metric, (:year if card.years), :subproject].compact
  end

  def tab_list
    active_tabs.each_with_object({}) do |tab, hash|
      icon, stat_method, title = TAB_MAP[tab]
      stat = card.send stat_method
      hash["#{tab}_tab".to_sym] = [fa_icon(icon), stat, title].join " "
    end
  end

  view :metric_tab do
    standard_nest :metric
  end

  view :company_tab do
    standard_nest :wikirate_company
  end

  view :year_tab do
    standard_nest :year
  end

  view :subproject_tab, template: :haml

  def copied_project_fields
    %i[wikirate_topic description].each_with_object({}) do |fld, hash|
      hash["_#{fld.cardname}"] = card.fetch(trait: fld, new: {}).content
    end
  end
end
