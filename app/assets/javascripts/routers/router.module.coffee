module.exports = class Router extends Backbone.Router
  _.extend @::, require('./application'), require('./dynamic')

  utils:      require('support/app_utils')
  formatters: require('support/formatters')
  settings:   require('support/settings')

  routes:
    # static routing
    '.*'                               : 'dashboard'
    'dashboard'                        : 'dashboard'
    'settings'                         : 'settingsUser'
    'settings/user'                    : 'settingsUser'
    'settings/company'                 : 'settingsCompany'
    'settings/data_integrations'       : 'settingsDataIntegrations'
    'settings/account'                 : 'settingsAccount'
    'settings/advisor'                 : 'settingsAdvisor'

    # dynamic routing
    'company/reports/:id'              : 'companyReportsShow'
    'company/reports/:id/:analysis_id' : 'companyReportsShow'
    ':type'                            : 'typeIndex'
    ':type/:analysis'                  : 'typeIndexAnalysis'
    ':type/:id/show'                   : 'typeShow'
    ':type/:id/:analysis'              : 'typeShowAnalysis'

  dashboard: ->
    if @company.isTrialExpired()
      @settingsAccount()
    else
      @renderView 'dashboard/index', ['dashboard']

  settingsCompany:          -> @renderView 'settings/company',           ['settings', 'company']
  settingsUser:             -> @renderView 'settings/user',              ['settings', 'user']
  settingsDataIntegrations: -> @renderView 'settings/data_integrations', ['settings', 'data_integrations']

  settingsAdvisor: ->
    return false unless app.company.isAdvisor()
    @renderView 'settings/advisor', ['settings', 'advisor']

  settingsAccount: ->
    return false if app.subscriber.isOverridden()
    @renderView('settings/account', ['settings', 'account'])

  companyReportsShow: (id, analysisId) ->
    analysisId ||= app.reports.get(id).analyses.first()?.id ? 'new'
    @renderView 'company/report', ['company', id, analysisId], reportId: id, analysisId: analysisId
    @currentView.renderMain()

  renderView: (viewPath, nav = [], viewOptions = {}) ->
    klass = require("views/#{viewPath}")
    @currentView.remove() if @currentView
    @currentView = new klass(viewOptions)
    mediator.trigger 'route:change', nav, viewOptions
    $('#page_content').html @currentView.render().el
    @currentView.renderMain() if @currentView.renderMain?
    mediator.trigger 'route:rendered', nav, viewOptions
