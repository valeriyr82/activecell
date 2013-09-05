module.exports = class Industries extends Backbone.Collection
  url: 'api/v1/industries'

  comparator: (industry) ->
    industry.get('name')
