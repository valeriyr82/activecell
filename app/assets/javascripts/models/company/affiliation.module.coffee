Model = require('models/shared/base_model')

module.exports = class Affiliation extends Model
  paramRoot: 'company_affiliation'
  urlRoot: 'api/v1/company/affiliations'
