class Card
  class AnswerQuery
    DB_COLUMN_MAP = {}.freeze

    def initialize filter, sort={}, paging={}
      prepare_filter_args filter
      prepare_sort_args sort
      @paging_args = paging

      @conditions = []
      @values = []
      @restrict_to_ids = Hash.new { |h, k| h[k] = [] }

      @temp_conditions = []
      @temp_values = []
      @temp_restrict_to_ids = Hash.new { |h, k| h[k] = [] }

      add_filter @filter_args
    end

    def self.default fixed_id, sort={}, paging={}
      new fixed_id, { latest: true }, sort, paging
    end

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      return missing_answers if find_missing?
      run_filter_query
    end

    def add_filter opts={}
      opts.each do |k, v|
        process_filter_option k, v
      end
    end

    def where additional_filter={}
      MetricAnswer.where where_args(additional_filter)
    end

    def count additional_filter={}
      where(additional_filter).count
    end

    def metric_value_query value
      case value.to_sym
      when :none
        missing_answers
      when :unknown
        filter :value, "Unknown"
      when :known
        filter :value, "Unknown", "<>"
      else
        if (period = timeperiod(value))
          filter :updated_at, Time.now - period, ">"
        end
      end
    end

    def category_query value
      filter :value, value
    end

    def range_query value
      filter :numeric_value, value[:from], ">="
      filter :numeric_value, value[:to], "<"
    end

    def year_query value
      if value.to_sym == :latest
        filter :latest, true
      else
        filter :year, value
      end
    end

    def filter key, value, operator=nil
      operator ||= value.is_a?(Array) ? "IN" : "="
      db_column = filter_key_to_db_column key
      @conditions << "#{db_column} #{operator} (?)"
      @values << value
    end

    private

    def find_missing?
      @filter_args[:metric_value] == :none
    end

    def run_filter_query
      MetricAnswer.fetch(where_args, @sort_args, @paging_args)
    end

    def prepare_filter_args filter
      @filter_args = filter
      @filter_args[:latest] = true unless filter[:year] || filter[:metric_value]
    end

    def prepare_sort_args args
      @sort_args = args
    end

    def set_temp_filter opts
      return unless opts.present?

      c, v, r = @conditions, @values, @restrict_to_ids
      @conditions = []
      @values = []
      @restrict_to_ids = Hash.new { |h, k| h[k] = [] }

      add_filter opts
      @restrict_to_ids.each do |key, values|
        filter key, values
      end

      @temp_conditions, @temp_values, @temp_restrict_to_ids =
        @conditions, @values, @restrict_to_ids
      @conditions, @values, @restrict_to_ids = c, v, r
    end

    # @return args for AR's where method
    def where_args temp_filter_opts={}
      set_temp_filter temp_filter_opts
      @restrict_to_ids.each do |key, values|
        filter key, values
      end
      [(@conditions+@temp_conditions).join(" AND ")] + @values + @temp_values
    end

    def process_filter_option key, value
      if exact_match_filters.include? key
        filter key, value
      elsif like_filters.include? key
        filter key, "%#{value}%", "LIKE"
      elsif card_id_filters.include? key
        filter key, to_card_id(value)
      elsif respond_to? "#{key}_query"
        send "#{key}_query", value
      end
    end

    def filter_key_to_db_column key
      self.class::DB_COLUMN_MAP[key] || key
    end

    def exact_match_filters
      self.class::SIMPLE_FILTERS
    end

    def like_filters
      self.class::LIKE_FILTERS
    end

    def card_id_filters
      self.class::CARD_ID_FILTERS
    end

    def to_card_id value
      if value.is_a?(Array)
        value.map { |v| Card.fetch_id(v) }
      else
        Card.fetch_id(value)
      end
    end

    def timeperiod value
      case value.to_sym
      when :today then
        1.day
      when :week then
        1.week
      when :month then
        1.month
      end
    end
  end
end
