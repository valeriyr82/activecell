BaseView      = require('views/shared/base_view')
SuggestedView = require('./suggested')
EditView      = require('./edit')
NewView       = require('./new')
RevenueStream = require('models/revenue_stream')

module.exports = class RevenueStreamsIndexListView extends BaseView
  template:      JST['revenue_streams/index']
  emptyTemplate: JST['revenue_streams/empty']
  events:
    'click .new-revenue-stream' : 'new'

  initialize: ->
    @collection = app.revenueStreams
    @addEvent @collection, 'destroy', @addEmptyMessage
    @addEvent @collection, 'add', @onAdd
    @addEvent @collection, 'add change destroy', @addSuggestedStreams

  render: (options) =>
    @$el.html @template()
    @addEmptyMessage()
    @addSuggestedStreams()
    @addAll()
    @

  renderMain: ->

  addEmptyMessage: =>
    if @collection.length is 0
      @$('.revenue-streams tbody').append @emptyTemplate()

  addSuggestedStreams: =>
    @$('.suggested-revenue-streams tbody').html('')
    for name in ['Customer service/support', 'Product revenue', 'Services revenue']
      view = @createView SuggestedView, name: name, collection: @collection
      @$('.suggested-revenue-streams tbody').append view.render().el

  addAll: ->
    @collection.each @addOne

  addOne: (revenueStream) =>
    view = @createView EditView, model: revenueStream, collection: @collection, className: 'edit-view'
    if @$('tr.new-view').length is 0
      @$('.revenue-streams tbody').append view.render().el
    else
      view.render().$el.insertBefore('.new-view')

  onAdd: (revenueStream) =>
    @$('.empty').remove() if @collection.length is 1
    @addOne(revenueStream)

  new: (event) ->
    if @$('tr.new-view').length is 0
      model = new RevenueStream()
      model.collection = @collection
      view  = @createView NewView, model: model, collection: @collection, className: 'new-view'
      @$('.revenue-streams tbody').append view.render().el
    @$('tr.new-view .name').focus()
