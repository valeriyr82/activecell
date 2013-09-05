Vendor    = require('models/vendor')

module.exports = class Vendors extends Backbone.Collection
  url: 'api/v1/vendors'
  model: Vendor
