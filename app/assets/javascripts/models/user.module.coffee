Companies = require('collections/companies')

module.exports = class User extends Backbone.Model
  paramRoot: 'user'
  urlRoot: 'api/v1/users'

  validate:
    name:
      required: true
    email:
      required: true
      type: 'email'

  initialize: ->
    @companies = new Companies(@get('companies'))

  getAvatarUrl: (options = {}) ->
    app.utils.getGravatarFor(@get('email'), options)

  updatePassword: (attributes, options = {}) ->
    $.ajax
      type: 'PUT'
      url: "#{@url()}/update_password"
      dataType: 'json'
      data:
        user: attributes
      success: options.success || ->
      error: options.error || ->
