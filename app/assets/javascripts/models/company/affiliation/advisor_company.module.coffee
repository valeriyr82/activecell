Affiliation = require('models/company/affiliation')

module.exports = class AdvisorCompanyAffiliation extends Affiliation

  getType: -> 'company'

  getName: ->
    @get('advisor_company').name

  getEmail: ->

  getAvatarUrl: ->
    @get('advisor_company').logo_url
