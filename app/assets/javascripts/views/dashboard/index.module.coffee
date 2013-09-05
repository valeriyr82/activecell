BaseView            = require('views/shared/base_view')
ActivityStreamView  = require('views/dashboard/activity_stream')
TaskListView        = require('views/dashboard/task_list')
DashboardMetricView = require('views/dashboard/metric')

module.exports = class DashboardIndexView extends BaseView
  template: JST['dashboard/index']
  className: 'row'

  initialize: ->
    @model = app.reports.dashboard()
    @addEvent @model, 'first_init', @render

  render: ->
    @$el.html @template()
    @renderMetrics()
    @renderActivityStream()
    @renderTaskList()
    @

  renderMetrics: ->
    _(4).times @renderMetricAt

  renderMetricAt: (index) =>
    metrics = @model.analyses
    metric = metrics.at(index)
    @renderMetric(metrics, metric, index)

  renderMetric: (metrics, metric, index) ->
    metricView = @createView DashboardMetricView, model: metric, collection: metrics
    @$(".metric:nth-child(#{index + 1})").html metricView.render().el

  renderActivityStream: ->
    activityView = @createView ActivityStreamView
    @$('#activity-stream-container').html activityView.render().el

  renderTaskList: ->
    taskView = @createView TaskListView
    @$('#task-list-container').html taskView.render().el
