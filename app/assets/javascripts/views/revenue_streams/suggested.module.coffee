BaseView   = require('views/shared/base_view')

module.exports = class RevenueStreamsSuggested extends BaseView
  template: JST['revenue_streams/suggested']
  tagName: 'tr'
  events:
    'click .add' : 'add'

  initialize: (options) ->
    {@name} = options
    @isUsed =  @collection.isUsed(@name)

  render: ->
    @$el.html @template(name: @name, isUsed: @isUsed)
    @

  add: (event) ->
    @collection.create name: @name
