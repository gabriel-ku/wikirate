class Card
  class Content
    module Chunk
      class FormulaInput < Nest
        Card::View::Options.add_option :year, :ruler
        Card::View::Options.add_option :company, :ruler
        Card::View::Options.add_option :unknown, :ruler
        Card::View::Options.add_option :not_researched, :ruler
        DEFAULT_OPTION = :year

        Card::Content::Chunk.register_class(
          self, prefix_re: '\\{\\{',
                full_re:    /^\{\{([^\}]*)\}\}/,
                idx_char:  "{"
        )
      end

      register_list :formula, [:FormulaInput]
    end
  end
end