module.exports = class SpinnerView extends Backbone.View
  el: '#spinner'

  initialize: ->
    @$el.on 'ajaxStart',    @show
    @$el.on 'ajaxComplete', @hide
    mediator.on 'route:change', @hide

  show: => @$el.spin(radius: 4, width: 2, length: 5, speed: 1.4, color: '#eee')
  hide: => @$el.spin(false)