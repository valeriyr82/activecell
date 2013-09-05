# Mixin with methods handling quick company addition form
# Note that you should implement _companyAdded in base class to make this work.
QuickCompanyForm = require('views/settings/company/quick_company_form')

module.exports = QuickCompanyFormHandlers =
  events:
    'click #add-company': 'renderCompanyForm'

  renderCompanyForm: (event) ->
    event?.preventDefault()
    $("#add-company").parent().toggle()
    
    # form need to know do we want to create company as a user or advisor
    createCompanyAs = @createCompanyAs ? 'user'
    formView = new QuickCompanyForm(as: createCompanyAs)
    
    callback = @_companyAdded ? ->
    formView.on("close", callback)
    
    @$('#company-form').html(formView.render().el)
