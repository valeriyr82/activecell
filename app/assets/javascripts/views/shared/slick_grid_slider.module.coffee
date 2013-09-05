# initiates the jscroll pane scrollbars
# currently we check the max-height to decide whether the scrollbar is needed
# there's an alternative workaround possible, see example:
# similar case described here: 
# http://stackoverflow.com/questions/9574865/jscrollpane-always-visible-displays-inside-accordion-content

# # fix for jScrollPane. We need to set element height so
# # jscrollpane don't render the vertical scrollbar
# # store the original height
#   originalHeight = elToScroll.css('height')
# # set the height inline style attribute so jscroll knows how to handle this
#   elToScroll.css('height', elToScroll.outerHeight() + 10)
#   elToScroll.jScrollPane(options)
# # bring back original height value or remove it if it was not set before
#   elToScroll.css('height', originalHeight)

module.exports = SlickGridSlider =
  sliderOptions : {
    showArrows: false
    verticalGutter: 10
    contentWidth: 1 # we don't want the horizontal bar
  }
  
  # Inits the slider
  # Don't ever use on existing slider
  initSlider : (tableEl) ->
#    console.warn 'init slider'
    return if @sliderObj
    @tableEl ||= tableEl
    return @removeScroll() unless @tableEl.length > 0
    @elToScroll = @tableEl.parent()
    # page still rendering or scroll not needed anyway
    return @removeScroll() if @contentSmallerThanMax()
    slider = @elToScroll.jScrollPane(@sliderOptions)
    @sliderObj = slider.data('jsp')

  updateSlider: (tableEl) ->
#    console.warn 'update slider', tableEl
    if @sliderObj
#      console.warn 'WAY slider reinitialise'
      @sliderObj.reinitialise()
    else
#      console.warn 'WAY slider init'
      @initSlider(tableEl)

  contentSmallerThanMax:  ->
    return false if @elToScroll.css('max-height') == 'none'
    return true if "#{@elToScroll.outerHeight()}px" <= @elToScroll.css('max-height')

  removeScroll: ->
    return false unless @sliderObj
    @sliderObj.destroy()
    @sliderObj = null

  hideIfExists: ->
    return false