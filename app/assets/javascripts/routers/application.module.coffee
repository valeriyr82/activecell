Bootstrapper  = require('lib/bootstrapper')
HeaderView    = require('views/layout/header')
FooterView    = require('views/layout/footer')
MainNavView   = require('views/layout/main_nav')
NavDispatcher = require('lib/nav_dispatcher')

module.exports =
  createApplication: () ->
    options = if $('#raw_data').length > 0 then JSON.parse $('#raw_data').html() else {}

    @stubDemoActions(options)
    @createModels(options)
    @initWidgets()
    @renderLayout(options)
    @initMainNav()

    @defer = $.Deferred()
    Bootstrapper.fetch @, =>
      mediator.trigger('app:init')
      Backbone.history.start()
      @defer.resolve()
      
    $(window).on "resize", -> mediator.trigger('window:resize')

  isLoaded: -> @defer

  stubDemoActions: (options) ->
    if options.isDemo
      for action in ['settingsAccount', 'settingsCompany', 'settingsUser', 'settingsAdvisor',
                     'settingsCustomizeColors', 'settingsDataIntegrations']
        @[action] = ->

  createModels: (options) ->
    for modelName in ['user', 'company', 'scenario', 'recurly/subscriber']
      objectName = _.last modelName.split('/')
      modelClassName = require("models/#{modelName}")
      modelAttributes = options[modelName]
      @[objectName] = new modelClassName(modelAttributes)

  initWidgets: ->
    for widgetName in ['loader', 'spinner']
      klass = require("views/layout/widgets/#{widgetName}")
      new klass()
  
  initMainNav: ->
    new MainNavView el: $('#main_nav')

  renderLayout: (options) ->
    new NavDispatcher()
    # TODO: fix global with mediator and events
    # https://github.com/profitably/active_cell/commit/ec5453ff9f420319ace2914595d7eb388538d47a
    @header = new HeaderView(isDemo: options.isDemo).render()
    @footer = new FooterView().render()
