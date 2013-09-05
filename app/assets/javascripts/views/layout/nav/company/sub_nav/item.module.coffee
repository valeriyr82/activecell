BaseView = require('views/shared/base_view')
EditView = require('./edit')

module.exports = class SubNavItemView extends BaseView
  template: JST['layout/nav/company/sub_nav/item']
  tagName: 'li'
  events:
    'click' : 'editName'

  initialize: ->
    @addEvent mediator, "reports:edit:#{@model.id}", @editName

  render: =>
    @$el.html @template(@model.toJSON())
    @$el.attr('data-sub-nav', @model.id)
    @

  editName: (event) ->
    if @$('form').length is 0 and ("#company/reports/#{@model.id}" is location.hash or
                                   "#company/reports/#{@model.id}" is location.hash.slice(0, location.hash.lastIndexOf('/')))
      event?.preventDefault()
      view = @createView EditView, model: @model
      @$el.append view.render().el
      @$('form input').focus()
