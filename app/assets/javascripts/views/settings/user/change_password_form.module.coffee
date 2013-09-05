BaseView   = require('views/shared/base_view')
FormErrors = require('views/shared/form_errors')

module.exports = class ChangePasswordForm extends BaseView
  _.extend(@::, FormErrors)
  template: JST['settings/user/change_password_form']

  events:
    'click .btn.submit': 'changePassword'

  render: ->
    @$el.html @template()
    @

  changePassword: (event) ->
    event?.preventDefault()

    attributes = @getFormAttributes()
    @model.updatePassword attributes,
      error: (response) =>
        errors = JSON.parse(response.responseText).errors
        @showErrors(errors)
      success: =>
        @$el.find('.password-changed-notification').show()
        @clearForm()

  getFormAttributes: ->
    @$el.find('form#user-password-form').serializeObject()

  clearForm: ->
    @$('.validation-error').hide()
    @$('input').val('')
