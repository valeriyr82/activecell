BaseView = require('views/shared/base_view')

module.exports = class CompanyLogo extends BaseView
  originalLogo: '/assets/branding/style_guide/logo/activecell-full-color-darkBG-small.png'
  logoPlaceholder: '/assets/placeholder_logo.png'

  template: JST['settings/company/logo']
  events:
    'click a.revert-original-state' : 'revertOriginalState'

  initialize: ->
    @model = app.company
    @addEvent @model, 'change', @render
    @addEvent @model, 'change:logo_url', @loadHeaderFooter

  render: =>
    @$el.html @template(@model.toJSON())
    @initUploadLogo()
    @

  initUploadLogo: =>
    @$('#fileupload').fileupload
      type: 'PUT'
      dataType:'json'
      maxFileSize: 5000000
      acceptFileTypes: /(\.|\/)(gif|jpg|jpeg|png)$/i
      add: (e, data) =>
        @updateLogoSrc '/assets/settings/loader.gif'
        data.submit()
      done:  =>
        # just reload the company and show a new logo
        @model.fetch
          error: -> l('error', arguments)
      error: (response) =>
        # display error messages and reset the logo
        @showLogoErrorMessage("must be in 'png/jpg/jpeg/gif' format")
        @resetLogo()

  # Load logo of header and footer with specific values
  loadHeaderFooter: (company) =>
    @$('.company-logo-section a.revert-original-state').show()
    app.header.loadLogo(company.get('logo_url'))

  # Reset logo of center page
  resetLogo: ->
    if @model.get('logo_file_name')
      @updateLogoSrc @model.get('logo_url')
    else
      @updateLogoSrc(@logoPlaceholder)

  # Upload logo source of center page
  updateLogoSrc: (src) =>
    $('.company-logo-section .logo').attr 'src', src

  # Revert specific logo to default logo
  revertOriginalState: ->
    @updateLogoSrc '/assets/settings/loader.gif'
    @model.resetLogo
      success: (current, resp) =>
        @updateLogoSrc(@logoPlaceholder)
        @$('.company-logo-section a.revert-original-state').hide()
        app.header.loadLogo(@originalLogo)
      error: (error) =>
        @resetLogo()
        alert 'Something went wrong. Please try again!'

  # Show error messages when upload failed
  showLogoErrorMessage: (message) ->
    $('.company-logo-section .error').html("")
    $('.company-logo-section .error').show()
    $('.company-logo-section .error').append "<div>#{message}</div>"

    setTimeout =>
      $('.company-logo-section .error').fadeOut()
    , 2000
