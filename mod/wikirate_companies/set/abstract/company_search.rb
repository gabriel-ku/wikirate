include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::CommonFilters

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

format do
  def filter_class
    CompanyFilterQuery
  end

  # TODO: bookmark
  def company_filter_map
    [
      { name: { lock: true, label: false } },
      :company_category,
      :company_group,
      :country
    ]
  end

  def default_sort_option
    "id"
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Answers": :answer, "Most Metrics": :metric }.merge super
  end
end

format :html do
  def default_sort_option
    "answer"
  end

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + dataset_quick_filters
  end
end