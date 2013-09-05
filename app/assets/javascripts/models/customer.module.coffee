Model = require('models/shared/base_model')

module.exports = class Customer extends Model
  @hasAnalyse 'revenue', plan: false

  trailing12mRevenue: () ->
    54321