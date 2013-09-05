Model = require('models/shared/base_model')
utils = require('analysis/shared/utils')

module.exports = class Vendor extends Model
  trailing12mSpend: () ->
    12345