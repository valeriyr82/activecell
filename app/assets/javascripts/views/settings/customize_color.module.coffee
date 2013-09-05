BaseView = require('views/shared/base_view')

# TODO: refactor color scheme views
module.exports = class CustomizeColor extends BaseView
  template: JST['settings/company/customize_color']
  hexInputTemplate: JST['settings/company/customize_color_hex_input']
  events:
    "click a.primary-light" : "loadDefaultPrimary"
    "click a.primary-dark" : "loadDefaultSecondary"

  initialize: =>
    @model = app.colorScheme
    @addEvent @model, 'change', @render

  render: =>
    if $.isEmptyObject(@model.toJSON())
      colorScheme = app.defaultColorScheme
    else
      colorScheme = @model.toJSON()
    @$el.html(@template(colorScheme)) if @model.isRender

    if $.isEmptyObject(app.colorScheme.toJSON())
      @loadDefaultColors()
      
    @initColorPicker()
    @

  # Show color picker
  initColorPicker: ->
    $picker = @$(".bar.clickable").colorpicker(format: 'hex')

    # Add an input with hex value
    $picker.on "show", (ev) =>
      colorPicker = $(ev.currentTarget).data('colorpicker')
      container = colorPicker.picker
      hexInput = container.find('input#hex-value')
      
      # if hexInput is not yet there. Append and bind the events
      if hexInput.length == 0
        container.append @hexInputTemplate()
        hexInput = container.find('#hex-value')
        
        # interrupted by the plugin
        hexInput.click (e) ->
          $(e.currentTarget).focus()
          
        # handle entering hex of known color
        hexInput.on 'keyup', (event) =>
          colorPicker.element.data('color', hexInput.val())
          colorPicker.update()
          colorPicker.element.trigger({
            type: 'changeColor',
            color: colorPicker.color
          })
          
        # blur the input when using mouse. Fix for events collision caused by
        # changeColor event
        container.find('.colorpicker-saturation').on 'mousedown', (e) =>
          hexInput.blur()
          
      hexInput.val(ev.color.toHex())
      
    $picker.on "hide", (ev) =>
      color = ev.color.toHex()
      old_color = @$(ev.target).attr("data-color")
      if old_color isnt color
        field = @$(ev.target).attr("data-object")
        attributes = {}
        attributes[field] = color
        @model.isRender = false
        @saveColor(attributes)

    $picker.on "changeColor", (ev) =>
      @loadColorsCustomization(@$(ev.target), ev.color.toHex())
      # Don't modify the input if it's in use
      unless $("#hex-value").is(':focus')
        $("#hex-value").val(ev.color.toHex())

  saveColor: (attributesHash) ->
    @model.save { "color_scheme": attributesHash },
      complete: (current, resp) =>
        @model.isRender = true
        @model.fetch()
      error: (error) ->
        alert 'Something went wrong. Please try again!'

  # Load colors customization after changed
  loadColorsCustomization: (currentObject, hex_color) =>
    switch(currentObject.attr("data-object"))
      when "primary_light"
        @primaryLightSection hex_color,  @$(".primary_dark").attr("data-color")
      when "primary_dark"
        @primaryDarkSection @$(".primary_light").attr("data-color"), hex_color
      # when "light_grey"
      #         @lightGreySection hex_color, @$(".grey").attr("data-color")
      #       when "grey"
      #         @greySection @$(".light_grey").attr("data-color"), hex_color
      #       when "white"
      #         @whiteSection hex_color
      #       when "secondary_light"
      #         @secondaryLightSection @$(".secondary_dark").attr("data-color"), hex_color
      #       when "secondary_dark"
      #         @secondaryDarkSection hex_color, @$(".secondary_light").attr("data-color")
      #       when "menu_other"
      #         @menuOtherSection hex_color, @$(".black").attr("data-color")
      #       when "dark_grey"
      #         @darkGreySection hex_color
      #       when "black"
      #         @blackSection @$(".menu_other").attr("data-color"), hex_color

  loadDefaultPrimary: ->
    colorScheme = app.defaultColorScheme
    @primaryLightSection colorScheme.primary_light, colorScheme.primary_dark
    @saveColor({primary_light: colorScheme.primary_light})
    
  loadDefaultSecondary: ->
    colorScheme = app.defaultColorScheme
    @primaryDarkSection colorScheme.primary_light, colorScheme.primary_dark
    @saveColor({primary_dark: colorScheme.primary_dark})

  # Reset colors to defaul after destroyed
  loadDefaultColors: =>
    colorScheme = app.defaultColorScheme

    # @menuOtherSection colorScheme.menu_other, colorScheme.black
    @primaryLightSection colorScheme.primary_light, colorScheme.primary_dark
    @primaryDarkSection colorScheme.primary_light, colorScheme.primary_dark
    # @lightGreySection colorScheme.light_grey, colorScheme.grey
    # @greySection colorScheme.light_grey, colorScheme.grey
    # @secondaryLightSection colorScheme.secondary_dark, colorScheme.secondary_light
    # @secondaryDarkSection colorScheme.secondary_light, colorScheme.secondary_dark
    # @darkGreySection colorScheme.dark_grey
    # @blackSection colorScheme.menu_other, colorScheme.black
    # @whiteSection colorScheme.white

  # For gradient background with moz browser
  mozGradient: (object, first_color, last_color) =>
    moz = "-moz-linear-gradient(#{last_color},#{first_color})"
    object.css "background", moz

  # For gradient background with webkit browser
  webkitGradient: (object, first_color, last_color) =>
    web = "-webkit-linear-gradient(#{last_color},#{first_color})"
    object.css "background", web

  # # For gradient background in center, top with moz browser
  # mozGradientCenter: (object, first_color) =>
  #   moz = "-moz-linear-gradient(center top , white, white 25%," + first_color + ")"
  #   object.css "background-image", moz
  # 
  # # For gradient background in center, top with webkit browser
  # webkitGradientCenter: (object, first_color) =>
  #   web = "-webkit-linear-gradient(center top , white, white 25%," + first_color + ")"
  #   object.css "background-image", web

  # Load colors customization after changed to primaryLightSection
  primaryLightSection: (first_color, last_color) =>
    @mozGradient $("body"), first_color, last_color
    @webkitGradient $("body"), first_color, last_color

  # Load colors customization after changed to primaryDarkSection
  primaryDarkSection: (first_color, last_color) =>
    @mozGradient $("body"), first_color, last_color
    @webkitGradient $("body"), first_color, last_color

  # # Load colors customization after changed to secondaryLightSection
  # secondaryLightSection: (first_color, last_color) =>
  #   @mozGradient $(".top-bar ul.nav .active a"), first_color, last_color
  #   @webkitGradient $(".top-bar ul.nav .active a"), first_color, last_color
  #   @mozGradient $(".top-bar ul.nav .active a:hover"), first_color, last_color
  #   @webkitGradient $(".top-bar ul.nav .active a:hover"), first_color, last_color
  # 
  # # Load colors customization after changed to secondaryDarkSection
  # secondaryDarkSection: (first_color, last_color) =>
  #   @mozGradient $(".top-bar ul.nav .active a"), first_color, last_color
  #   @webkitGradient $(".top-bar ul.nav .active a"), first_color, last_color
  #   @mozGradient $(".top-bar ul.nav .active a:hover"), first_color, last_color
  #   @webkitGradient $(".top-bar ul.nav .active a:hover"), first_color, last_color
  # 
  # # Load colors customization after changed to menuOtherSection
  # menuOtherSection: (first_color, last_color) =>
  #   @mozGradient $(".top-bar a.tab"), first_color, last_color
  #   @webkitGradient $(".top-bar a.tab"), first_color, last_color
  #   @mozGradient $(".top-bar .fill"), first_color, last_color
  #   @webkitGradient $(".top-bar .fill"), first_color, last_color
  # 
  # # Load colors customization after changed to whiteSection
  # whiteSection: (hex_color) =>
  #   app.header.$(".header-btn-group span.label").css "color", hex_color
  #   app.header.$(".btn.primary-alt").css "color", hex_color
  #   app.header.$(".fill .company-select").css "color", hex_color
  #   app.header.$(".fill button.user-settings").css "color", hex_color
  # 
  #   # For top bar
  #   $(".top-bar .nav a").css "color", hex_color
  #   $(".top-bar a.current-scenario").css "color", hex_color
  #   $(".top-bar a.current-scenario, .top-bar a.date-range, .top-bar a.compare-cta, .top-bar a.compare-to").css "color", hex_color
  #   $(".top-bar a.date-range .start, .top-bar a.date-range .end").css "color", hex_color
  #   $(".top-bar a.date-range .to").css "color", hex_color
  #   $(".top-bar ul.nav .active a").css "color", hex_color
  # 
  # # Load colors customization after changed to lightGreySection
  # lightGreySection: (first_color, last_color) =>
  #   @mozGradient app.footer.$("footer"), first_color, last_color
  #   @webkitGradient app.footer.$("footer"), first_color, last_color
  # 
  # # Load colors customization after changed to greySection
  # greySection: (first_color, hex_color) =>
  #   @mozGradient app.footer.$("footer"), first_color, hex_color
  #   @mozGradient app.footer.$("footer"), first_color, hex_color
  # 
  #   # For middle bar
  #   @mozGradientCenter $(".middle-bar .nav a"), hex_color
  #   @webkitGradientCenter $(".middle-bar .nav a"), hex_color
  #   @mozGradientCenter $(".middle-bar .fill"), hex_color
  #   @webkitGradientCenter $(".middle-bar .fill"), hex_color
  #   $(".middle-bar .nav a").css "background-color", hex_color
  #   $(".middle-bar .fill").css "background-color", hex_color
  #   $(".middle-bar .nav .active > a").css "background", hex_color
  # 
  # # Load colors customization after changed to darkGreySection
  # darkGreySection: (hex_color) =>
  #   $(".middle-bar .nav .active > a").css "color", hex_color
  # 
  # # Load colors customization after changed to blackSection
  # blackSection: (first_color, last_color) =>
  #   @mozGradient $(".top-bar a.tab"), first_color, last_color
  #   @webkitGradient $(".top-bar a.tab"), first_color, last_color
  #   @mozGradient $(".top-bar .fill"), first_color, last_color
  #   @webkitGradient $(".top-bar .fill"), first_color, last_color
