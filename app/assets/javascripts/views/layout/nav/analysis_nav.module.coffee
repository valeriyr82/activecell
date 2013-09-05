BaseView      = require('views/shared/base_view')
ItemView      = require('./analysis_nav/item')
MiniChartView = require('views/shared/d3_chart/mini_view')

module.exports = class AnalysisNavView extends BaseView
  template: JST['layout/nav/analysis_nav/list']
  tagName: 'ul'
  className: 'analysis-nav'

  initialize: (options) ->
    {@type, @analysisId, @prefix} = options
    @showId = options.id
    @analysisItems = app.settings.getItems(@type, @prefix)

  render: ->
    @$el.html @template(prevTop: @prevTop)
    # TODO 45342: analysisView creates again inside this method as in router.renderView,
    # it calls analysis initialize method at least twice
    @addOne(analysisId, name) for analysisId, name of @analysisItems
    @

  addOne: (analysisId, name) ->
    path = if @prefix is 'index' then "#{@type}/#{analysisId}" else "#{@type}/#{@showId}/#{analysisId}"
    analysisKlass = require("views/#{@type}/#{@prefix}_#{analysisId}")
    analysisView = @createView analysisKlass, id: @showId
    itemView = @createView ItemView,
      name: name
      analysisId: analysisId
      path: path
      metricValue: analysisView.metricValue()
    @$el.append itemView.render().el
    miniChartView = @createView MiniChartView, analysisView.miniChartOptions()
    $(itemView.el).find('.mini-chart').html miniChartView.render().el

  changeActive: (analysisId) ->
    $newNav  = @$("li##{analysisId}")
    newIndex = @$('li').index($newNav) - 1

    @$('li.active').removeClass('active')
    @$('.nav-ribbon').animate({top: 73*newIndex}, 200, -> 
      $('.analysis-nav li.active').removeClass('active')
      $newNav.addClass('active'))
    
