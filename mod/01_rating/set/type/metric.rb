card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

card_accessor :metric_type,
              :type=>:pointer, :default=>"[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type

def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename.to_sym
end

def metric_designer
  cardname.parts[0]
end

def metric_designer_card
  self[0]
end

def metric_title
  cardname.parts[1]
end

def metric_title_card
  self[1]
end

def question_card
  field('Question', new:{})
end

def value_type
  # FIXME: value type should have a codename
  (vt = field('value type')) && vt.item_names.first
end

def value_options
 (vo = field('value options')) && vo.item_names
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type == 'Categorical'
end

def researched?
  metric_type_codename == :researched
end

def calculated?
  !researched?
end

def scored?
  metric_type_codename == :score ||
    metric_type_codename == :wiki_rating
end

def analysis_names
  return [] unless (topics = fetch(trait: :wikirate_topic)) &&
                   (companies = fetch(trait: :wikirate_company))
  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company.to_name.tag}+#{topic}"
    end
  end.flatten
end

# def value company, year
#   (value_card = Card["#{name}+#{company}+#{year}+#{value}"]) &&
#     value_card.content
# end

def companies_with_years_and_values
  metric_value_cards.map do |mv_card|
    [mv_card.company, mv_card.year, mv_card.value]
  end
end

def random_value_card
  metric_value_cards(limit: 1).first
end

def random_valued_company_card
  return unless (rvc = random_value_card)
  rvc.company_card
end

def metric_value_cards opts={}
  Card.search({ left: { left: { left: name },
                right: { type: 'year' } },
                right: 'value'
              }.merge(opts))
end

format :html do
  view :tabs do |args|
    lazy_loading_tabs args[:tabs], args[:default_tab],
                      render("#{args[:default_tab]}_tab", skip_permission: true)
  end
  def default_tabs_args args
    args[:tabs] = {
      'Details' => path(view: 'details_tab'),
      "#{fa_icon :comment} Discussion" => path(view: 'discussion_tab')
    }
    args[:default_tab] = 'Details'
  end

  # tabs for metrics of type formula, score and WikiRating
  # overriden for researched
  view :details_tab do
    output [
             nest(card.formula_card, view: :titled, title: 'Formula'),
             nest(card.about_card, view: :titled, title: 'About')
           ]
  end

  view :discussion_tab do |args|
    _render_comment_box(args)
  end

  def css
    css = <<-CSS
    .titled-view.TYPE_PLUS_RIGHT-metric-formula {
      .TYPE_PLUS_RIGHT-metric-formula.card-content {
        font-size: 1.5em;
        font-weight: bold;
      }
    }
      .metric-thumbnail {
        font-size: 0.66em;
        font-weight: normal;
        border: solid 1px #ebebeb;
        display: inline-block;
        padding: 7px;
        img {
          max-width: 35px;
          max-height: 35px;
        }
        .thumbnail-image, .thumbnail-text {
          display: inline-block;
          vertical-align: middle;
        }
      }
    CSS
    "<style> #{Sass.compile css}</style>"
  end


  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  def item_wrap args
    with_nest_mode :normal do
      wrap args do
        <<-HTML
        <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
        <div class="yinyang-row">
          <div class="metric-item value-item">
            #{yield}
            <div class="details"></div>
          </div>
        </div>
        HTML
      end
    end
  end

  view :item_view do |args|
    append = args[:append_for_details] ||
             "#{card.key}+add_to_formula"
    item_wrap(args) do
      <<-HTML
      <div class="header metric-details-toggle"
           data-append="#{append}">
        #{_render_handle if args[:draggable]}
        #{_render_vote if args[:vote]}
        <div class="logo hidden-xs hidden-md">
          #{nest card.metric_designer_card.fetch(trait: :image), view: :core,
                 size: 'small'}
        </div>
        <div class="name">
          #{nest card.metric_title_card, view: :name}
        </div>
      </div>
      HTML
    end
  end

  view :item_view_with_value do |args|
    contributions_url = path "#{metric_designer}+contributions"
    item_wrap args do
      <<-HTML
        <div class="header">
          #{_render_handle if args[:draggable]}
          #{_render_vote if args[:vote]}
          <a href="#{contributions_url}">
          <div class="logo hidden-xs hidden-md">
             #{nest card.metric_designer_card.fetch(trait: :image),
                    view: :core, size: 'small'}
          </div>
          </a>
          <div class="name">
            #{card_link card, text: metric_title, class: 'inherit-anchor'}
          </div>
        </div>
        <div class="data metric-details-toggle"
             data-append="#{card.key}+add_to_formula">
          #{_render_value(args)}
          <div class="data-item show-with-details text-center">
            <span class="label label-metric">
             #{card_link card, text: 'Metric Details'}
            </span>
          </div>
        </div>
      HTML
    end
  end

  view :handle do |args|
    content_tag :div, class: 'handle' do
      glyphicon 'option-vertical'
    end
  end

  view :vote do |args|
    %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
  end

  view :value do |args|
    return '' unless args[:company]
    <<-HTML
          <div class="data-item hide-with-details">
            {{#{card.name}+#{args[:company]}+latest value|concise}}
          </div>
    HTML
  end

  def view_caching?
    true
  end
end

format :json do
  view :content do
    companies_with_years_and_values.to_json
  end
end

# The new metric form has a title and a designer field instead of a name field
# We compose the card's name here
event :set_metric_name, :initialize,
      on: :create,
      when: proc { |c| c.needs_name? } do
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end

def needs_name?
  # score names are handles differently in MetricType::Score
  !name.present? && metric_type != 'Score'
end