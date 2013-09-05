BaseView = require('views/shared/base_view')
FormErrors = require('views/shared/form_errors')
SubdomainGenerator = require('lib/subdomain_generator')

module.exports = class SettingsQuickCompanyForm extends BaseView
  _.extend(@::, FormErrors)
  template: JST['settings/company/form_for_advisor']
  
  events:
    'submit form#company-for-advisor': 'createCompany',
    'keyup #company-for-advisor input#company_name': 'generateSuggestedSubdomain'

  initialize: (options) ->
    @createAs = options.as || 'user'
    @currentCompany = app.company

  render: ->
    @$el.html @template()
    $('.company-form-container').show()
    @

  destroy: ->
    @$el.html ''
  
  createCompany: (event) ->
    event?.preventDefault()
    ajaxOptions =
      data: company: @getFormAttributes()
      success: =>
        @trigger("close")
        @destroy()
      error: (response) =>
        errors = JSON.parse(response.responseText).errors
        @showErrors(errors)
    
    if @createAs == 'user'
      @currentCompany.create(ajaxOptions)
    else if @createAs == 'advisor'
      @currentCompany.createAdvisedCompany(ajaxOptions)
    
  getFormAttributes: ->
    @$el.find('form#company-for-advisor').serializeObject()


  generateSuggestedSubdomain: (event) ->
    name = $(event.currentTarget).val()
    generator = new SubdomainGenerator(name)
    @$el.find('#company-for-advisor input#company_subdomain').val(generator.generate())
