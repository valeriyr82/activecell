module.exports = class BaseModel extends Backbone.Model
  @hasAnalyse: (analyseName, options = {}) ->
    analyse         = require("analysis/#{options.file ? _.toUnderscore(analyseName)}")
    options.name    = @['name'].toLowerCase()
    options.groupBy = [options.name + '_id']
    extend = analyse['extend'](analyseName, options)
    _.extend @::, extend
