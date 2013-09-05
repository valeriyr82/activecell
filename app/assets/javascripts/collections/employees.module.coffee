Employee    = require('models/employee')

module.exports = class Employees extends Backbone.Collection
  url: 'api/v1/employees'
  model: Employee