Affiliation = require('models/company/affiliation')

module.exports = class AdvisedCompanyAffiliation extends Affiliation
  urlRoot: 'api/v1/company/advised_company_affiliations'

  updateOverrideBranding: (override) ->
    @save(override_branding: override, { wait: true })

  updateOverrideBilling: (override) ->
    @save(override_billing: override, { wait: true })
