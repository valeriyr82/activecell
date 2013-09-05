Affiliation = require('models/company/affiliation')

module.exports = class ContributorAffiliation extends Affiliation
  getType: -> 'user'

  getName: ->
    @get('user').name

  getEmail: ->
    @get('user').email

  getAvatarUrl: ->
    app.utils.getGravatarFor(@getEmail())
