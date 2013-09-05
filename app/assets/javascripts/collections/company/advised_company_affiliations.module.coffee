module.exports = class AdvisedCompanyAffiliations extends Backbone.Collection
  url: 'api/v1/company/advised_company_affiliations'
  model: require('models/company/affiliation/advised_company')
