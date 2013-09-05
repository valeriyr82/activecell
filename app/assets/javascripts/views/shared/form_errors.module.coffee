# Mixin with some helper methods for displaying validation errors
module.exports = FormErrors =
  # Defines error messages to show in the UI
  # @see https://github.com/n-time/backbone.validations#how-to-use
  validationMessages:
    required: "Can't be blank"
    url:      "Is not an url address"
    email:    "Is not an email address"

  # Generate nice error message for given error types
  # For example: "Can't be blank, Is not an url address"
  validationMessageFor: (types...) ->
    (types.map (type) => @validationMessages[type] || type).join(', ')

  showErrorsFor: ($field, errorTypes...) ->
    @cleanupIndicatorsFor($field)

    template = JST['shared/form/field_error']
    message = @validationMessageFor(errorTypes...)
    $field.parent().append(template(fieldId: $field.attr('id'), message: message))

  showErrors: (errors) ->
    for fieldName, errorTypes of errors
      $field = @$("input[name='#{fieldName}']")
      @showErrorsFor($field, errorTypes...)

  cleanupIndicatorsFor: ($field) ->
    fieldId = $field.attr('id')
    @$el.find("span.indicator.#{fieldId}").remove()
