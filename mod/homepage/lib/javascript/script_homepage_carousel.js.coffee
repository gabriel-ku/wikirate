decko.slotReady (slot) ->
  # slot.find('._metric_value_examples').slick
  #   dots: true,
  #   infinite: true,
  #   speed: 500,
  #   fade: true,
  #   cssEase: 'linear'
  slot.find('#company-n-topic .company-list .search-result-list, #company-n-topic .topic-list .search-result-list').slick
    slidesToShow: 3
    slidesToScroll: 3
    dots: true
    variableWidth: true
    responsive: [
      {
        breakpoint: 1210
        settings:
          slidesToShow: 2
          slidesToScroll: 3
          infinite: true
          dots: true
      }
      {
        breakpoint: 800
        settings:
          slidesToShow: 1
          slidesToScroll: 2
      }
    ]
  slot.find('#banner_column1').slick
    dots: true
    autoplay: true
    autoplaySpeed: 15000
  slot.find('.x-carousal .pointer-list').slick
    dots: true,
    autoplay: true,
    autoplaySpeed: 15000,
    adaptiveHeight: false,
    fade: true,
    cssEase: 'linear',
  slot.find('#top-banner-wrapper .column-1 .SELF-video_image').click ->
    $('#wikirate-info-video').dialog
      modal: true
      width: 'auto'
      close: (event, ui) ->
        $('#wikirate-info-video').dialog 'destroy'
        return
    return

$(document).ready ->
  $('._wodry_company').wodry({
    animation: 'rotateX',
    delay: 5000,
    animationDuration: 2000
  })
  $('._wodry_topic').wodry({
    animation: 'rotateX',
    delay: 5000,
    animationDuration: 2000
  })
  $('._wodry_adjective').wodry({
    animation: 'rotateX',
    delay: 5000,
    animationDuration: 2000
  })

  $(document).on 'scroll', () ->
    getNumbers().forEach (element) ->
      if (isScrolledIntoView(element))
        animation(element)

  #options = { useEasing: true, useGrouping: true, separator: ',', decimal: '.', };
  #demo = new CountUp('myTargetElement', 0, 4775, 0, 2.5, options);
  #demo.start()

  # patch for bootstrap bug on homepage carousel tabs
  # After the upgrade to Bootstrap 4, the "previous" tabs were not getting deactivated properly.
  # This may be because of an interaction between the tabs and the carousels inside them (?)
  # the following restores the expected behavior by removing the active class from the previous tab.
  # it also deals with a follow-up problem in which carousel items were not activating correctly
  $('body').on 'shown.bs.tab', '.intro-tabs .nav-link', (e)->
    activateIntroTab this

activateIntroTab = (tab)->
  panels = $('.intro-tab-panels .tab-pane')
  target = $(tab).data 'target'

  other_panels = panels.not target
  other_panels.removeClass 'active'
  other_panels.find('.carousel').carousel('pause')

  panels.find('.carousel-item').removeClass 'active'

  active_panel = panels.filter target
  active_panel.find('.carousel').carousel()
  active_panel.find('.carousel-item').first().addClass 'active'

getNumbers = () -> 
  values = []
  $('.text-right.mx-3').each -> 
    values.push( $(this).find('h1.font-weight-normal') )
  values
  
isScrolledIntoView = (elem) ->
  docViewTop = $(window).scrollTop();
  docViewBottom = docViewTop + $(window).height();
  elemTop = $(elem).offset().top;
  elemBottom = elemTop + $(elem).height();
  ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));

animation = (elem) ->
  # animation CountUp.js

# $('.intro-tab-panels .tab-pane').not().removeClass 'active'
    #    targetTab = $(e.target).data('target')
    #    console.log targetTab
    #    $(targetTab).find('.slick-next').trigger 'click'
