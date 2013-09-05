FormView = require('./form')

module.exports = class RevenueStreamsNew extends FormView
  save: (event) ->
    newName = super(event)
    @model.set {name: newName}, error: @displayError

    if @model.isValid()
      @collection.create(@model)
      @$('.name').val('')

  onEsc: -> @remove()