BaseView               = require('views/shared/base_view')
FormView               = require('views/settings/user/form')
ChangePasswordFormView = require('views/settings/user/change_password_form')
CompaniesView          = require('views/settings/user/companies')

module.exports = class User extends BaseView
  template: JST['settings/user/index']

  initialize: ->
    @model = app.user

  render: ->
    @$el.html @template(@model.toJSON())

    @_renderSection @$('#user-info'), FormView
    @_renderSection @$('#user-change-password'), ChangePasswordFormView
    @_renderSection @$('#user-companies'), CompaniesView
    @

  _renderSection: ($element, klass) ->
    view = @createView klass, model: @model
    $element.html view.render().el
