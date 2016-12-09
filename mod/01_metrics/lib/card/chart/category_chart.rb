class Card
  module Chart
    class CategoryChart < VegaChart
      def generate_data
        Card[@metric_id].value_options.each do |category|
          add_data category: category
        end
      end

      private

      def x_axis
        super.merge title: "Categories"
      end

      def data_item_hash filter
        super.merge x: filter[:category]
      end

      # @return true if the given category is supposed to be highlighted
      def highlight? filter
        return true unless @highlight_value
        @highlight_value == filter[:category]
      end
    end
  end
end
