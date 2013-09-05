SubNavView     = require('../sub_nav')
SubNavItemView = require('./sub_nav/item')

module.exports = class CompanySubNavView extends SubNavView
  events:
    'click .new-report'      : 'newReport'
    'click .dropdown-toggle' : 'toggleDropdown'

  initialize: (@mainNav, options) ->
    super
    @collection = app.reports.customReports()
    @model      = @collection.get(options.reportId)

    @addEvent @collection, 'add change', @refresh
    @addEvent mediator, 'active_report:destroy', @destroyReport

  refresh: ->
    @render()
    @afterRender()
    @changeActive(@activeNav)

  afterRender: ->
    # TODO: with complete design add check for breadcrumbs
    #       and make it more dynamic
    @maxWidth = 500
    @collection?.each @addOne

  addOne: (report) =>
    view = @createView SubNavItemView, model: report, attributes: {'data-nav': report.id}

    @$('.sub-nav > li.dropdown').before view.render().el
    unless @$('.sub-nav').width() < @maxWidth
      @$('.sub-nav > li.dropdown').show()
      @$('.sub-nav ul.dropdown-menu').append @$('.sub-nav > li.dropdown').prev()

  newReport: ->
    app.reports.create {name: 'Custom Report', created_at: new Date(), report_type: 0}, wait: true, success: (model) =>
      model.analyses.reportId = model.id
      @collection = app.reports.customReports()

      app.navigate("company/reports/#{model.id}", true)
      mediator.trigger("reports:edit:#{model.id}")

  destroyReport: ->
    @model.destroy()
    app.navigate('company', true)

  toggleDropdown: ->
    @$('ul.dropdown-menu').toggle()
