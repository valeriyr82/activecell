#= require ./form.module
FormView = require('./form')

module.exports = class RevenueStreamsEdit extends FormView
  editEvents:
    'click .edit' : 'edit'

  initialize: ->
    super
    @events = _.extend({}, @events, @editEvents)
    @addEvent @model, 'change', @render

  render: =>
    super
    @$('.edit-td').hide()
    @$('.show-td').show()
    @

  edit: (event) ->
    @$('.show-td').hide()
    @$('.edit-td').show()
    @$('.name').focus()

  save: ->
    newName = super(event)
    if @model.get('name') is newName
      @render()
    else
      @model.save { name: newName }, error: @displayError

  destroy: ->
    message = "Are you sure want to remove #{@model.get('name')}?"
    bootbox.confirm message, (confirmed) =>
      return unless confirmed

      @model.destroy()
      @remove()

  onEsc: -> @render()
