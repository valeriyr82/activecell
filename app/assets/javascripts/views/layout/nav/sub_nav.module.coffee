BaseView = require('views/shared/base_view')

module.exports = class SubNavView extends BaseView

  initialize: (@mainNav) ->
    { @company, @subscriber } = app

    # re-render when the company has been upgraded / downgraded
    @addEvent @company, 'change:_type', @render

  render: ->
    # Hide the menu when trial period expired
    unless @company.isTrialExpired()
      template = @getTemplate()
      @$el.html template(company: @company, subscriber: @subscriber)
    @

  changeActive: (@activeNav) ->
    @$('li.active').removeClass('active')
    @$("[data-sub-nav=#{@activeNav}]").addClass('active')

  getTemplate: ->
    JST["layout/nav/sub_nav/#{@mainNav}"]
