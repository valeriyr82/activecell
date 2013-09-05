BaseView = require('views/shared/base_view')

module.exports = class ComingSoonView extends BaseView
  template: JST['base_page/coming_soon']

  metricValue: ->
    app.formatters.intCommas(Math.random() * 1000) + 'km'
  
  miniChartOptions: ->
    switch Math.round(Math.random())
      when 0
        {
          type: 'spark line'
          data: [1,2,3,2,3,4,3,4,5,4,5,6,5,6,7,6,7,8]
        }
      when 1
        {
          id: 'reach'
          type: 'column'
          data: [
              {"label":"FL", "val":30000 }
              {"label":"CA", "val":20000 }
              {"label":"NY", "val":30000 }
              {"label":"NC", "val":40000 }
              {"label":"SC", "val":50000 }
              {"label":"AZ", "val":60000 }
            ]
        }
  
  dashboardOptions: -> null
