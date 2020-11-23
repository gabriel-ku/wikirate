class Card
  class VegaChart
    # Company count histograms.  Each vertical bar represents a range of values
    class Histogram < VegaChart
      include Helper::SingleMetric
      include Helper::Axes
      include Helper::AnswerValues
      include Helper::Highlight

      def hash
        super.tap do |hash|
          hash[:signals] << { name: "extent", init: extent }
        end
      end

      private

      def extent
        "[data('extremes')[0].min_value, data('extremes')[0].max_value]"
      end

      def layout
        with_answer_values { super.merge builtin(:histogram) }
      end

      def x_axis
        super.merge title: value_title, format: "~s" # number formatting
      end

      def y_axis
        super.merge count_axis
      end

      def highlight_transform
        super.tap do |t|
          t[:expr] = "(highlight >= datum.bin0 && highlight < datum.bin1) " \
                     "|| datum.bin1 == toNumber(highlight)"
        end
      end
    end
  end
end
