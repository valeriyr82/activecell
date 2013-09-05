Subscriber            = require('models/recurly/subscriber')
ColorScheme           = require('models/color_scheme')
Revenue               = require('analysis/revenue')
SalesMarketingExpense = require('analysis/sales_marketing_expense')

module.exports = Bootstrapper =
  fetch: (context, callback) ->
    $.getJSON('bootstrap.json').pipe (json) =>
      @initContext(json, context, callback)
    , -> console.error('not correct format of json')

  initContext: (json, context, callback) ->
    context.defaultColorScheme = json.defaultColorScheme
    context.colorScheme        = new ColorScheme(json.color_scheme)

    @createCollections(json, context)
    @createAnalysis(context)
    callback.call(context)

  createCollections: (json, context) ->
    collections = ['periods', 'accounts', 'scenarios', 'products', 'revenue_streams', 'reports',
                   'customers', 'channels', 'segments', 'stages', 'employees', 'employee_types', 'vendors',
                   'categories', 'financial_summary', 'conversion_summary', 'conversion_forecast']
    for collectionName in collections
      klass = require("collections/#{collectionName}")
      context[_.toCamel collectionName] = new klass(json[collectionName])

  createAnalysis: (context) ->
    context.revenue               = new Revenue()
    context.salesMarketingExpense = new SalesMarketingExpense()
