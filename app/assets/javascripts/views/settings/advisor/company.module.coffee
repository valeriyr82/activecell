BaseView = require('views/shared/base_view')

module.exports = class SettingsAdvisorCompany extends BaseView
  template: JST['settings/advisor/company']
  tagName: 'tr'

  events:
    'click a.btn.remove-company': 'removeCompany'
    'click a.btn.log-on': 'changeCompany'
    'click input[name=override_branding]': 'overrideBranding'
    'click input[name=override_billing]': 'overrideBilling'

  initialize: ->
    { @subscriber, @currentCompany, @user } = app
    @addEvent @model, 'change', @render

  render: =>
    @$el.addClass("affiliation-#{@model.id}")
    @$el.html @template(affiliation: @model.toJSON(), hasActiveSubscription: @subscriber.hasActiveSubscription())
    @

  overrideBranding: (event) ->
    @_showSpinnerFor('branding')
    override = $(event.target).is(':checked')
    @model.updateOverrideBranding(override)

  overrideBilling: (event) ->
    @_showSpinnerFor('billing')
    override = $(event.target).is(':checked')
    @model.updateOverrideBilling(override)

  removeCompany: (event) ->
    event?.preventDefault()

    bootbox.confirm 'Are you sure?', (confirmed) =>
      return unless confirmed

      @model.removeAdvisedCompany
        success: =>
          @collection.fetch()
          @collection.trigger("reset")

  changeCompany: (event) ->
    subdomain = @model.get('company').subdomain
    app.utils.switchToCompany(subdomain, true)

  _showSpinnerFor: (section) ->
    template = JST['shared/form/field_saving']
    @$(".override-#{section}").html(template(fieldId: @model.id))
