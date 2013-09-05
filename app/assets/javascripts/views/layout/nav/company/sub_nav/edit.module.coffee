BaseView = require('views/shared/base_view')

module.exports = class SubNavEditView extends BaseView
  template: JST['layout/nav/company/sub_nav/edit']
  tagName: 'form'
  events:
    'submit'     : 'save'
    'blur input' : 'save'

  render: =>
    @$el.html @template(@model.toJSON())
    @

  save: (event) ->
    event.preventDefault()
    @model.save name: @$('input').val()
    @remove()
