Reports = require('collections/reports')

try
  Backbone.history.start silent: true
catch e

describe 'BaseRouter', ->
  beforeEach ->
    spyOn($, 'ajax')
    app.reports = new Reports()
    app.reports.add {id: 'report', name: 'Stub', report_type: 1}
    @router   = app
    @routeSpy = jasmine.createSpy('router_spy')

  testRoutes =
    'settings'                   : 'settingsUser'
    'settings/user'              : 'settingsUser'
    'settings/company'           : 'settingsCompany'
    'settings/company/colors'    : 'settingsCustomizeColors'
    'settings/data_integrations' : 'settingsDataIntegrations'
    'settings/account'           : 'settingsAccount'
    'settings/advisor'           : 'settingsAdvisor'
    'company'                    : 'typeIndex'
    'company/burn_runway'        : 'typeIndexAnalysis'
    'company/reports/report'     : 'companyReportsShow'
    'company/reports/report/new' : 'companyReportsShow'
    'channels'                   : 'typeIndex'
    'channels/reach'             : 'typeIndexAnalysis'
    'channels/conversion'        : 'typeIndexAnalysis'
    'dashboard'                  : 'dashboard'
    ''                           : 'dashboard'

  for route, method of testRoutes
    do (route, method) ->
      it "should call #{method} on #{route}", ->
        $.when(@router.isLoaded()).then =>
          @router.on("route:#{method}", @routeSpy)
          @router.navigate(route, true)
          expect(@routeSpy).toHaveBeenCalled()
