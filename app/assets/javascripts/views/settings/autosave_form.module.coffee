BaseView   = require('views/shared/base_view')
FormErrors = require('views/shared/form_errors')

module.exports = class AutosaveForm extends BaseView
  _.extend(@::, FormErrors)

  events:
    'blur input': 'save'
    'change select': 'save'
    'change input[type="checkbox"]': 'save'

  render: ->
    @$el.html @template(@model.toJSON())
    @

  save: (event) ->
    event?.preventDefault()

    $changedField = $(event.target)
    fieldName = $changedField.attr('name')
    newValue = @extractFieldValue($changedField)

    valueWasChanged = @model.get(fieldName) != newValue
    if valueWasChanged
      @showSpinnerFor($changedField)

      attributes = {}
      attributes[fieldName] = newValue

      @model.save attributes,
        wait: true
        error: (model, errors) =>
          # extract server side errors if xhr, otherwise render client side errors
          errors = JSON.parse(errors.responseText).errors if errors.responseText?
          @showErrors(errors)
        success: => @showSuccessFor($changedField)

  showSpinnerFor: ($field) ->
    @cleanupIndicatorsFor($field)

    template = JST['shared/form/field_saving']
    $field.parent().append(template(fieldId: $field.attr('id')))

  showSuccessFor: ($field) ->
    @cleanupIndicatorsFor($field)

    template = JST['shared/form/field_saved']
    $field.parent().append(template(fieldId: $field.attr('id')))

  extractFieldValue: ($field) ->
    if $field.is(':checkbox')
      $field.is(':checked')
    else
      $field.val()
