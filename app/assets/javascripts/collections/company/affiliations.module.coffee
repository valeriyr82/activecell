module.exports = class CompanyAffiliations extends Backbone.Collection
  url: 'api/v1/company/affiliations'
  model: require('models/company/affiliation')

  parse: (resp, xhr) ->
    AdvisorCompanyAffiliation = require('models/company/affiliation/advisor_company')
    ContributorAffiliation = require('models/company/affiliation/contributor')

    _(resp).map (attrs) ->
      switch attrs._type
        when 'AdvisorCompanyAffiliation' then new AdvisorCompanyAffiliation(attrs)
        when 'UserAffiliation' then new ContributorAffiliation(attrs)
