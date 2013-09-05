module.exports = class Category extends Backbone.Collection
  url: 'api/v1/categories'

  defaultId: () ->
    app.categories.first().get('id')