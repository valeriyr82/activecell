User = require('models/user')

module.exports = class Users extends Backbone.Collection
  url: 'api/v1/users'
  model: User

  searchByName: (searchPhrase) ->
    pattern = new RegExp(searchPhrase, 'i');
    @filter (user) ->
      pattern.test(user.get('name'));
      
  without: (id) ->
    @filter (user) ->
      id != (user.get('id'));