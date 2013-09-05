BaseView = require('views/shared/base_view')
AdvisedCompanyAffiliations = require('collections/company/advised_company_affiliations')
SettingsAdvisorCompany = require('views/settings/advisor/company')
QuickCompanyFormHandlers = require('views/shared/quick_company_form_handlers')

module.exports = class SettingsAdvisor extends BaseView
  _.extend(@::, QuickCompanyFormHandlers)

  createCompanyAs: 'advisor'

  template: JST['settings/advisor']

  initialize: ->
    { @subscriber } = app

    @collection = new AdvisedCompanyAffiliations()
    @collection.fetch()
    @addEvent @collection, 'reset', @renderCompanies

  render: =>
    @$el.html @template(companies: @collection.toJSON(), hasActiveSubscription: @subscriber.hasActiveSubscription())
    @

  renderCompanies: =>
    @$el.find('table.companies tbody tr').remove()
    @collection.each @addOne

  addOne: (company) =>
    companyView = @createView SettingsAdvisorCompany, model: company, collection: @collection
    @$el.find('table.companies tbody').append companyView.render().el

  _companyAdded: =>
    $("#add-company").parent().toggle()
    @collection.fetch()
    @collection.trigger("reset")
