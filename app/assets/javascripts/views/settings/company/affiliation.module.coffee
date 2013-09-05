BaseView = require('views/shared/base_view')

module.exports = class SettingsCompanyAffiliation extends BaseView
  template: JST['settings/company/affiliation']
  tagName: 'tr'

  events:
    'click .grant-access': 'grantAccess'
    'click .revoke-access': 'revokeAccess'

  initialize: ->
    @user = app.user
    @addEvent @model, 'change', @render

  render: =>
    @$el.addClass("company-affiliation-#{@model.id}")
    @$el.html @template(@templateContext())
    @

  grantAccess: (event) ->
    event?.preventDefault()
    @_showSpinner()
    @model.save(has_access: true, { wait: true })

  revokeAccess: (event) ->
    event?.preventDefault()
    @_showSpinner()
    @model.save(has_access: false, { wait: true })

  templateContext: ->
    id: @model.id
    avatarUrl: @model.getAvatarUrl()
    name: @model.getName()
    email: @model.getEmail()
    type: @model.getType()
    hasAccess: @model.get('has_access')
    overrideBilling: @model.get('override_billing')
    # TODO refactor this
    currentUser: @model.getType() is 'user' and @model.get('user').id is @user.id

  _showSpinner: ->
    template = JST['shared/form/field_saving']
    @$('.has-access').html(template(fieldId: @model.id))
