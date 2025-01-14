class Card
  # extends CardQuery to look up companies' countries in card table
  module CompanyAnswerQuery
    def company_country val
      joins << company_answer_join(:countries)
      add_answer_condition CompanyFilterQuery.country_condition, val
    end

    def company_category val
      joins << company_answer_join(:categories)
      add_answer_condition CompanyFilterQuery.category_condition, val
    end

    def company_answer val
      Array.wrap(val).each_with_index do |constraint, index|
        table = "co_ans#{index}"
        joins << company_answer_join(table)
        @conditions << CompanyFilterQuery.company_answer_condition(table, constraint)
      end
    end

    private

    def company_answer_join answer_alias
      Query::Join.new side: :left, from: self, from_field: "id",
                      to: [:answers, answer_alias, :company_id]
    end

    def add_answer_condition cond, val
      @conditions << ::Answer.sanitize_sql_for_conditions([cond, Array.wrap(val)])
    end
  end
end
