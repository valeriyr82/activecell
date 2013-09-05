AutosaveForm = require('views/settings/autosave_form')
Countries    = require('collections/countries')
Industries   = require('collections/industries')

module.exports = class CompanyForm extends AutosaveForm
  template: JST['settings/company/form']
  selectOptionTemplate: JST['shared/select_option']

  render: =>
    @$el.html @template(@model.toJSON())

    @initCountries()
    @initIndustries()
    @

  initCountries: ->
    @countries = new Countries()
    @countries.fetch()
    @addEvent @countries, 'reset', @renderCompanyCountry

  renderCompanyCountry: =>
    $countrySelect = @$('#company_country_id')

    @countries.each (country) =>
      $countrySelect.append @selectOptionTemplate(id: country.id, name: country.get('name'))
    $countrySelect.prepend @selectOptionTemplate(id: '', name: 'Not selected')
    $countrySelect.val @model.get('country_id')

  initIndustries: ->
    @industries = new Industries()
    @industries.fetch()
    @addEvent @industries, 'reset', @renderCompanyIndustry

  renderCompanyIndustry: =>
    $industrySelect = @$('#company_industry_id')

    @industries.each (industry) =>
      $industrySelect.append @selectOptionTemplate(id: industry.id, name: industry.get('name'))
    $industrySelect.prepend @selectOptionTemplate(id: '', name: 'Not selected')
    $industrySelect.val @model.get('industry_id') || ''
