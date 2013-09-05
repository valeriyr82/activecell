Account = require('models/account')

module.exports = class Accounts extends Backbone.Collection
  url: 'api/v1/accounts'
  model: Account

  filterIds: (method) ->
    @chain().select((account) ->
      account[method]()
    ).pluck('id').value()
