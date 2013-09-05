Product    = require('models/product')

module.exports = class Products extends Backbone.Collection
  url: 'api/v1/products'
  model: Product