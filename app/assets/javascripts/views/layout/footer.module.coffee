module.exports = class Footer extends Backbone.View
  template: JST['layout/footer']
  el: '#footer'

  initialize: ->
    {@company} = app

  render: =>
    @$('.right-col').prepend @template()
    @
