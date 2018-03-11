format :json do
  view :search_factories, cache: :never do
    ids = if keyword
            search_by_company_name | search_by_address
          elsif country_code
            factory_ids
          end
    company_traits(ids).to_json
  end

  def company_traits ids
    return [] unless ids.present?
    ids.map do |id|
      company_name = Card.fetch_name(id)
      { name: company_name, id: id, url_key: company_name.url_key }
    end
  end

  def search_by_company_name
    wql = { type_id: WikirateCompanyID, name: ["match", keyword], return: :id }
    wql[:id] = ["in"].concat(factory_ids) if factory_ids.present?
    Card.search wql
  end

  def search_by_address
    Answer.where(*search_by_address_sql(factory_ids)).pluck(:company_id)
  end

  ADDRESS_SQL = "metric_id = ? AND value LIKE ?".freeze

  def search_by_address_sql company_ids
    address_metric_id = Card.fetch_id "Clean_Clothes_Campaign+Address"
    sql = if company_ids.present?
            ["company_id IN (?) AND (#{ADDRESS_SQL})", company_ids]
          else
            [ADDRESS_SQL]
          end
    sql.push(address_metric_id).push("%#{keyword}%")
  end

  def factory_ids
    @factory_ids ||= search_factory_ids
  end

  def search_factory_ids
    wql = { type_id: Card::WikirateCompanyID,
            left_plus: [{ id: Card.fetch_id("Clean Clothes Campaign+Supplier Of") }, {}],
            return: :id }
    if country_code
      wql[:right_plus] = [{ codename: "headquarters" },
                          { refer_to: { codename: country_code.to_s } }]
    end
    Card.search wql
  end

  def country_code
    params[:country_code] if params[:country_code].present?
  end

  def keyword
    params[:keyword] if params[:keyword].present?
  end
end