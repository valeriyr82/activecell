BaseView = require('views/shared/base_view')

module.exports = class AddMetricToDashboardView extends BaseView
  template:     JST['shared/modal/add_metric_to_dashboard']
  className: 'modal hide fade add-metric-to-dashboard'
  
  events:
    'click .btn-aim'            : 'btnSelected'
    'click .type-create-report' : 'createReport'
    'keyup .new-report-name'    : 'inputChanged'

  initialize: (existingAnalyses = {}, type = '') ->
    if existingAnalyses.length and type isnt ''
      @render(existingAnalyses, type)

  render: (existingAnalyses, type) ->
    @$el.html @template
      analyses : existingAnalyses
      type     : type
    @show()

  show: ->
    @$el.modal()
    $('.modal-open').bind('keyup', (e) =>
      # escape to close modal window
      if e.keyCode is 27
        @$el.modal('hide')
    )

  inputChanged: (e) ->
    if e.keyCode is 13
      mediator.trigger('metric-report:selected', {id : '', type: 'create-report', newName: e.target.value})
      @$el.modal('hide')
      @remove()

  createReport: (e) ->
    $(e.target).hide()
    $('.new-report-name').show()

  btnSelected: (e) ->
    regExp = /type-([^\s]+)/i
    className = regExp.exec e.target.className
    if className? and className[0] is 'type-create-report'
      return
    if className?
      mediator.trigger('metric-report:selected', {id : e.target.id, type: className[0].replace('type-', '')})
    @$el.modal('hide')
    @remove()
    
