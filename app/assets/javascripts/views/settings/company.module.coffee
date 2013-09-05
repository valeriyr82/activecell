BaseView            = require('views/shared/base_view')
CompanyForm         = require('views/settings/company/form')
CompanyLogo         = require('views/settings/company/logo')
CompanyAffiliations = require('views/settings/company/affiliations')
CustomizeColor      = require('views/settings/customize_color')

module.exports = class Company extends BaseView
  template: JST['settings/company/index']

  initialize: ->
    @model = app.company

  render: =>
    @$el.html @template(@model.toJSON())

    @renderForm()
    @renderUploadLogo() unless @model.isBrandingOverridden()
    @renderCustomizeColors()
    @renderAffiliations()
    @

  renderForm: ->
    formView = @createView CompanyForm, model: @model
    @$('#company-form').html formView.render().el

  renderUploadLogo: ->
    logoView = @createView CompanyLogo, model: @model
    @$('#company-logo').html logoView.render().el

  renderCustomizeColors: ->
    view = @createView CustomizeColor
    @$('#company-colors').html view.render().el

  renderAffiliations: ->
    affilicationsView = @createView CompanyAffiliations, model: @model
    @$('#company-affiliations').html affilicationsView.render().el
