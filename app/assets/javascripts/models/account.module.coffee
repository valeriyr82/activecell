module.exports = class Account extends Backbone.Model
  paramRoot: 'account'

  isRevenue: -> @get('type') is 'Revenue'
  isSalesMarketing: -> @get('activecell_category') is 'sales & marketing'

  trailing12mRevenue: () ->
    54321
    
  trailing12mSpend: () ->
    12345