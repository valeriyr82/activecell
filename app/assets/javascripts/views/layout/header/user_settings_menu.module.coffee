BaseView = require('views/shared/base_view')

module.exports = class UserSettingsMenuView extends BaseView
  template: JST['layout/header/user_settings_menu']
  events:
    'click button.user-settings' : 'toggleSettings'
    'click li a.change-company'    : 'changeCompany'

  initialize: (options = {}) ->
    @addEvent app.user, 'change:email', @render
    @addEvent app.company, 'change:advisor', @render

  render: =>
    @$el.html @template @prepareParams()
    @

  prepareParams: ->
    user:             app.user
    companies:        app.user.companies?.models
    company:          app.company
    advisedCompanies: app.company.advisedCompanies?.models
    subscriber:       app.subscriber
    isTrialExpired:   app.company.isTrialExpired()
    avatarUrl:        app.user.getAvatarUrl()

  changeCompany: (event) ->
    companyId  = $(event.target).attr('company-id')
    otherCompany = app.user.companies.get(companyId)
    app.utils.switchToCompany(otherCompany.get('subdomain'))

  toggleSettings: (event) ->
    event.stopPropagation()

    if @$('ul.companies').is(':visible')
      $('body').off('click')
      @$('ul.companies').hide()
    else
      $('body').on 'click', (event) => @$('ul.companies').hide()
      @$('ul.companies').show()
