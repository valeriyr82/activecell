BaseView = require('views/shared/base_view')

module.exports = class RevenueStreamsForm extends BaseView
  template: JST['revenue_streams/form']
  error:    JST['revenue_streams/error']
  tagName: 'tr'
  events:
    'click .delete' : 'destroy'
    'click .save'   : 'save'
    'submit form'   : 'save'
    'keyup .name'   : 'cancel'
    'keydown .name' : 'cleanError'

  render: =>
    @$el.html @template(@model.toJSON())
    @

  save: (event) ->
    event.preventDefault()
    @$('.name').val()

  cancel: (event) ->
    if event.keyCode is 27 then @onEsc()

  displayError: (model, error) =>
    @$('form').append @error(error)

  cleanError: (event) ->
    @$('.errors').remove()

  destroy: -> @remove()