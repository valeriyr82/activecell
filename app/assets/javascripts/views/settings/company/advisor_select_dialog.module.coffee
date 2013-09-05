BaseView = require('views/shared/base_view')

module.exports = class AdvisorSelectDialog extends BaseView
  template: JST['settings/company/advisor_select_dialog']
  selectOptionTemplate: JST['shared/select_option']

  events:
   'submit form.advisor-companies-selection': 'selectAdvisor'
   'click .add-as-user .btn' : 'inviteAsUser'

  initialize: (options) ->
    @affiliations  = options.affiliations
    @company    = app.company
    @user       = options.user
    @user.email = options.email

  render: ->
    @$el.html @template(user: @user, firstCompany: @collection.first().toJSON())
    @renderCompanies()
    @

  renderCompanies: ->
    $companySelect = @$('select#company_id')
    @collection.each (company) =>
      $companySelect.append @selectOptionTemplate(id: company.id, name: company.get('name'))

  selectAdvisor: (event) ->
    event?.preventDefault()

    advisorCompanyId = @$el.find('option:selected').val()
    @company.inviteAdvisorByCompany advisorCompanyId,
      success: @_handleSuccess
      error: (response) =>
        messages = JSON.parse(response.responseText).errors
        @$('.validation-error').text("Advisor company #{messages.advisor_company_id}") if messages.advisor_company_id

  inviteAsUser: (event) =>
    event?.preventDefault()

    @company.inviteUser @user.email,
      ignoreIfAdvisor : true
      success: @_handleSuccess
      error: @_handleError

  _handleSuccess: =>
    @affiliations.fetch
      success: @_close

  _close: ->
    $('#ajax-modal').modal('hide')

  _handleError: (response) =>
    data = JSON.parse(response.responseText)
    @_close()
    messages = data.errors
    if response.getResponseHeader('x-invitation-type') is 'CompanyInvitation'
      $('.validation-error').text("User email #{messages.email}") if messages.email
    else
      $('.validation-error').text('User is already in the company') if messages.user_id
