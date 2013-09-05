module.exports = class StyleBaseView extends Backbone.View
  win: $(window)
  subnav: null
  navTop: null
  isFixed: 0

  render: =>
    # block all empty links
    @$("a[href='#']").click (event)-> event.preventDefault()

    @$el.html @template()
    @initSubnav()
    @initPlugins()
    @

  remove: =>
    super
    @subnav.off()
    @window.off()

  initSubnav: ->
    @subnav = $('.subnav')
    @navTop = $('.subnav').length && $('.subnav').offset().top - 40
    @subnav.click(@subnavClick)
    @win.scroll(@processScroll)

  initPlugins: ->
    @$("a[rel=popover]").popover()
    @$(".tooltip").tooltip()
    @$("a[rel=tooltip]").tooltip()

  subnavClick: =>
    if !@isFixed
      setTimeout( =>
        @win.scrollTop(@win.scrollTop() - 47)
        10)

  processScroll: =>
    scrollTop = @win.scrollTop()
    if scrollTop >= @navTop && !@isFixed
      @isFixed = 1
      @subnav.addClass('subnav-fixed')
    else if scrollTop <= @navTop && @isFixed
      @isFixed = 0
      @subnav.removeClass('subnav-fixed')
