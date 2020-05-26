# Specifies the structure of a import item for an answer import.
class AnswerImportItem < ImportItem
  @columns = { metric: { map: true },
               wikirate_company: { map: true, auto_add: true },
               year: { map: true },
               value: {},
               source: { map: true, separator: ";", auto_add: true },
               comment: { optional: true } }

  def import_hash
    return {} unless (metric_card = Card[metric])

    metric_card.create_answer_args translate_row_hash_to_create_answer_hash
  end

  def normalize_value val
    if Card[metric]&.try :categorical? # really only needed for multicategory...
      val.split(";").compact.map(&:strip)
    else
      val
    end
  end

  def map_source val
    result = Card::Set::Self::Source.search val
    # result.first.id if result.size == 1
    #
    # FIXME: below is temporary solution to speed along FTI duplicates.
    # above is preferable once we have matching.
    result.first&.id
  end

  def translate_row_hash_to_create_answer_hash
    r = @row.clone
    translate_company_args r
    r[:year] = r[:year].cardname if r[:year].is_a?(Integer)
    r[:ok_to_exist] = true
    r = prep_subfields r
    handle_source_auto_add r
    r
  end

  # overridden in relationship import item
  def translate_company_args hash
    handle_company_auto_add hash, :wikirate_company, :auto_add_company

    hash[:company] = hash.delete :wikirate_company
  end

  def handle_source_auto_add hash
    return unless @auto_add[:source]

    hash[:source][:trigger_in_action] = :auto_add_source
  end

  def handle_company_auto_add hash, field, event
    return unless @auto_add[field]

    hash[:trigger_in_action] ||= []
    hash[:trigger_in_action] << event
  end

  class << self
    def wikirate_company_suggestion_filter_mark
      "Company+browse_company_filter"
    end

    def metric_suggestion_filter_mark
      "Metric+browse_metric_filter"
    end

    # will need to be able to filter by url for this to work well
    # def source_suggestion_filter_mark
    #   "Source+browse_source_filter"
    # end
  end
end