BaseView    = require('views/shared/base_view')
CompanyView = require('views/settings/user/company')
Companies   = require('collections/companies')
QuickCompanyFormHandlers = require('views/shared/quick_company_form_handlers')

module.exports = class UserCompanies extends BaseView
  _.extend(@::, QuickCompanyFormHandlers)
  
  template: JST['settings/user/companies']

  initialize: ->
    @collection = new Companies()
    @collection.fetch()

    @addEvent @collection, 'reset', @render
    @addEvent @collection, 'remove', @render

  render: =>
    @$el.html @template()
    for company in @collection.models
      companyView = @createView CompanyView, collection: @collection, model: company
      @$el.find('table.companies tbody').append companyView.render().el
    @

  _companyAdded: =>
    $("#add-company").parent().toggle()
    @collection.fetch()
    @collection.trigger("reset")
