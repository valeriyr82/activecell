Company = require('models/company')

module.exports = class Companies extends Backbone.Collection
  url: 'api/v1/companies'
  model: Company
