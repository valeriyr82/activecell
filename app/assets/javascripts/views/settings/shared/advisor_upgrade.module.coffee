BaseView = require('views/shared/base_view')

module.exports = class AdvisorUpgrade extends BaseView
  template: JST['settings/shared/advisor_upgrade']
  events:
    'click a.btn.upgrade-to-advisor': 'toggleAdvisor'

  initialize: ->
    @model = app.company

    # re-render when the company has been upgraded / downgraded
    @addEvent @model, 'change:_type', @render

  render: =>
    @$el.html @template
      advisor: @model.isAdvisor(),
      name: @model.get('name')
    @

  toggleAdvisor: (event) ->
    event?.preventDefault()
    @model.toggleAdvisor
      success: (company) =>
        if company.isAdvisor()
          app.settingsAdvisor()
