class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a single company is passed as company option.
          # It makes the values for this input item independent of the output company
          # (since the answer for company of the company option is always used)
          # Example:
          #   {{ M1 | company: Death Star }}
          module RelatedCompanies
            # extend AddValidationChecks

            # add_validation_checks :check_company_option

            def year_answer_pairs
              each_input_answer answer_query_relation, {} do |input_answer, hash|
                hash[input_answer.year] ||= []
                hash[input_answer.year] << input_answer
              end
            end

            def answer_query_relation
              Card::AnswerQuery.new(
                metric_id: input_card.id,
                company_group: company_option_card.id
              ).lookup_relation
            end

            private

            def requested_company_group_name
              @requested_company_id ||= company_option.card_id
            end
          end
        end
      end
    end
  end
end
