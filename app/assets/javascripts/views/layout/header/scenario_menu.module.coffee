BaseView  = require('views/shared/base_view')
Scenarios = require('collections/scenarios')

module.exports = class ScenarioMenuView extends BaseView
  template: JST['layout/header/scenario_menu']

  events:
    'click button.scenario-select'  : 'toggleScenarioSelect'

  initialize: (options = {}) ->
    @addEvent app.user, 'change:email', @render
    @addEvent app.company, 'change:advisor', @render
    @scenarios = [{name: 'Base'}]

  render: =>
    @$el.html @template(currentScenario: app.scenario, scenarios: @scenarios)
    @

  toggleScenarioSelect: (event) ->
    event.stopPropagation()

    if @$('ul.scenarios').is(':visible')
      @$('ul.scenarios').hide()
      $('body').off('click')
    else
      $('body').on 'click', (event) => @$('ul.scenarios').hide()
      @$('ul.scenarios').show()
