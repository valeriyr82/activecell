MainNavView            = require('views/layout/nav/main_nav')
SubnavView             = require('views/layout/nav/sub_nav')
AnalysisNavView        = require('views/layout/nav/analysis_nav')
BreadcrumbsView        = require('views/layout/nav/breadcrumbs')
CompanySubNavView      = require('views/layout/nav/company/sub_nav')
CompanyAnalysisNavView = require('views/layout/nav/company/analysis_nav')
CompanyAnalysisNavFoot = require('views/layout/nav/company/analysis_nav/footer')

module.exports = class NavDispatcher
  constructor: ->
    mediator.on 'route:change', @navChange

  navChange: (nav, options = {}) =>
    [mainNav, subNav, analysisNav] = nav
    @changeMainNav(mainNav)
    @controlVisible(mainNav, subNav, analysisNav, options)
    $('.company-analysis-nav-footer').remove()

  controlVisible: (mainNav, subNav, analysisNav, options) ->
    if mainNav is 'dashboard'
      $('#sub_nav, #analysis_nav, #breadcrumbs').hide()
    else
      $('#sub_nav').show()
      @changeSubNav(mainNav, subNav, options)

      if mainNav is 'settings'
        $('#analysis_nav, #breadcrumbs').hide()
      else
        $('#analysis_nav, #breadcrumbs').show()
        @changeAnalysisNav(mainNav, subNav, analysisNav, options)
        @changeBreadcrumbs(options)
    
  changeMainNav: (mainNav) ->
    @mainNavView ||= new MainNavView()
    @mainNavView.changeActive(mainNav) unless @mainNavView.activeNav is mainNav

  changeSubNav: (mainNav, subNav, options) ->
    if @currentSubNav isnt subNav
      @prepareSubNavView(mainNav, subNav, options)
      @subNavView.changeActive(subNav)

  prepareSubNavView: (mainNav, subNav, options) ->
    if !@subNavView or @subNavView.activeNav isnt subNav
      @subNavView?.remove()

      @subNavView = if mainNav is 'company'
        new CompanySubNavView(mainNav, options)
      else
        new SubnavView(mainNav)

      $('#sub_nav').html @subNavView.render().el
      @subNavView.afterRender() if mainNav is 'company'
      
  changeAnalysisNav: (mainNav, subNav, analysisNav, options) ->
    @prepareAnalysisNavView(mainNav, subNav, analysisNav, options)
    @analysisNavView.changeActive(analysisNav)

  prepareAnalysisNavView: (mainNav, subNav, analysisNav, options) ->
    if @currentSubNav isnt subNav or
       @currentPrefix isnt options.prefix or
       (options.analysisId is 'new' or @currentAnalysisId is 'new')

      [@currentSubNav, @currentPrefix, @currentAnalysisId] = [subNav, options.prefix, options.analysisId]
      prevTop = $('#analysis_nav .nav-ribbon').css('top')
      @analysisNavView?.remove()

      @analysisNavView = if mainNav is 'company' and options.reportId
        new CompanyAnalysisNavView(options)
      else
        new AnalysisNavView(options)

      @analysisNavView.prevTop = prevTop
      $('#analysis_nav').html @analysisNavView.render().el
      
      if mainNav is 'company' and options.reportId
        @analysisNavFooter ||= new CompanyAnalysisNavFoot(options.reportId)
        $('.page-content-wrapper').append @analysisNavFooter.render().el

  changeBreadcrumbs: (options) ->
    @breadcrumbsView ||= new BreadcrumbsView()
    @breadcrumbsView.setOptions(options).render()
