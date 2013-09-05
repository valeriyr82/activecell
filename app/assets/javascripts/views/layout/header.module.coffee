ScenarioMenuView     = require('views/layout/header/scenario_menu')
UserSettingsMenuView = require('views/layout/header/user_settings_menu')
BaseView             = require('views/shared/base_view')

module.exports = class HeaderView extends BaseView
  el: '#header'

  render: ->
    @renderScenarioMenu()
    @renderUserSettingsMenu()
    @

  renderScenarioMenu: ->
    scenarioMenu = @createView ScenarioMenuView
    @$('#scenario-menu').html scenarioMenu.render().el

  renderUserSettingsMenu: ->
    if app?.user # user is logged in
      userSettingsMenu = @createView UserSettingsMenuView
      @$('#user-settings-menu').html userSettingsMenu.render().el

  loadLogo: (url) ->
    @$("img.logo").attr "src", url
