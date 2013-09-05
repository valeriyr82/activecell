module.exports = class LoaderView extends Backbone.View
  el: '#loader'

  initialize: ->
    mediator.on('app:init', @hide)

  hide: => @$el.hide()
