BaseView            = require('views/shared/base_view')
AdvisorSelectDialog = require('views/settings/company/advisor_select_dialog')
Companies           = require('collections/companies')

module.exports = class SettingsCompanyInvitations extends BaseView
  template: JST['settings/company/invitations']
  tagName: 'div'

  events:
    'click .btn.invite': 'invite'

  initialize: ->
    @company = app.company

  invite: (event) ->
    event?.preventDefault()

    byEmail = $.trim @$('#invited-user-email').val()
    @company.inviteUser byEmail,
      ignoreIfAdvisor: @company.isAdvisor()
      success: @_handleSuccess
      error: @_handleError

  _handleSuccess: (data, textStatus, response) =>
    @render()

    if response.getResponseHeader('x-invitation-type') is 'CompanyInvitation'
      alert('Invitation was sent!')
    else
      @collection.fetch()

  _handleError: (response) =>
    data = JSON.parse(response.responseText)
    if data.errors
      messages = data.errors
      if response.getResponseHeader('x-invitation-type') is 'CompanyInvitation'
        @$('.validation-error').text("User email #{messages.email}") if messages.email
      else
        @$('.validation-error').text('User is already in the company') if messages.user_id
    else
      @_showAdvisorSelectDialogFor(data)

  _showAdvisorSelectDialogFor: (data) ->
    {user, email, companies} = data
    advisorCompanies = new Companies(companies)

    selectDialog = @createView AdvisorSelectDialog,
      collection: advisorCompanies,
      user: user, email: email,
      affiliations: @collection

    $('#ajax-modal').html selectDialog.render().el
    $('#ajax-modal').modal('show')
