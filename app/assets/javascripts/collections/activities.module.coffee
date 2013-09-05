module.exports = class Activities extends Backbone.Collection
  url: 'api/v1/activities'
  model: require('models/activity')

  paginate: (page, perPage) ->
    messagesTillTheEnd = @length - (page * perPage - perPage)
    # Return if requested page is out of the data's scope
    return [] if messagesTillTheEnd < 0
    
    # Set the correct amount of objects to return
    # page limit or less if this is the last page of the collection
    messagesTillTheEnd = perPage if messagesTillTheEnd > perPage
    
    _.last(@first(page * perPage), messagesTillTheEnd)