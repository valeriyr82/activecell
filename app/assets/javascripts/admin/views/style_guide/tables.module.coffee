StyleBaseView = require('./style_base_view')

module.exports = class Tables extends StyleBaseView
  el: '#container'
  template: JST['admin/style_guide/tables']

  initialize: ->
    $('li.style_guide_tables').addClass('active')
    @chartWidth = 940
    @calcultePercents()

  render: =>
    super
    @$('#pivottable').click()

  toogleChart: (event) =>
    element = $(event.target)
    chart_name = element.attr('id')

    @$('#chart-icons li').removeClass('over')
    element.addClass('over')

    $('#chart').fadeOut 'slow', =>
      $('#chart').empty()
      @['show' + _.toCamel(chart_name)]()
      $('#chart').fadeIn()

  showPivottable: =>
    ReportGrid.pivotTable "#chart",
      axes: ["model", "quarter", "market", "value"]
      datapoints: @pivotalData

  showSankey: =>
    ReportGrid.sankey "#chart",
      axes: ["billions"]
      datapoints: @simpleSankeyData
      options:
        width: @chartWidth

  showBar: =>
    ReportGrid.barChart "#chart",
      axes: ["country","count"]
      datapoints: @simpleBarData
      options:
        displayrules: true
        width: @chartWidth

  showStackedarea: =>
    ReportGrid.barChart "#chart",
      axes: ["gender","count"]
      datapoints: @multipleBarData
      options:
        width: @chartWidth
        segmenton: "age"
        label:
          datapointover: (dp) ->
            ReportGrid.format(dp.count) + " individuals in the years range "+dp.age

  showPercentarea: =>
    ReportGrid.barChart "#chart",
      axes: ["date","percent"]
      datapoints: @barPercentData
      options:
        width: @chartWidth
        segmenton: "country"
        label:
          tickmark: (v, a) ->
            if a == 'date' then v else ReportGrid.format(v * 100, "P:0")
        labelorientation: "aligned"

  showLine: =>
    ReportGrid.lineChart "#chart",
      axes: ["year", "population"]
      datapoints: @lineDate
      options:
        width: @chartWidth
        displayrules: true
        labelangle: (a) ->
          if a == "year" then 140 else 0
        labelanchor: (a) ->
          if a == "year" then "left" else "right"
        label:
          axis: (a) ->
            a
          tickmark: (v, a) ->
            if a == 'year' then v else ReportGrid.format(v)
          datapointover: (dp) ->
            ReportGrid.format(dp.population) + " individuals"

  showBubble: =>
    ReportGrid.scatterGraph "#chart",
      axes: ["year", "population"]
      datapoints: @lineDate
      options:
        width: @chartWidth
        label:
          tickmark: (v, t) ->
            if t == "year" then v else ReportGrid.format(v)
          axis: (t) ->
            ReportGrid.humanize(t)
          datapointover: (dp, stats) ->
            "year: " + dp.year + ", population: " + ReportGrid.format(dp.population) + ", area: " + ReportGrid.format(dp.area)
        displayrules: true,
        symbol: (dp) =>
          ReportGrid.symbol("circle", dp.area / @max * 400)
        labelangle: (a) ->
          if a == 'population' then 0 else 45

  showLeaderboard: =>
    ReportGrid.leaderBoard "#chart",
      axes: ["country", "count"],
      data: @simpleBarData

  showGeo: =>
    ReportGrid.geo "#chart",
      axes: ["code", "summerGold"]
      datapoints: @geoData
      options:
        width: @chartWidth
        map:
          template: "world"
          property: "code"
          color: "i:#EEE,#09F,#F63"
          label:
            datapointover: (dp, stats) ->
              dp.country + ": " + ReportGrid.format(dp.summerGold) + " gold medals"

  pivotalData: [
    { model: "Small",  market: "New York", quarter: "Q1",  value: 102970.0 }
    { model: "Small",  market: "New York", quarter: "Q2",  value: 125118.0 }
    { model: "Small",  market: "New York", quarter: "Q3",  value: 97509.0 }
    { model: "Small",  market: "Boston", quarter: "Q1",  value: 148008.0 }
    { model: "Small",  market: "Boston", quarter: "Q2",  value: 67982.0 }
    { model: "Small",  market: "Boston", quarter: "Q3",  value: 58262.0 }
    { model: "Small",  market: "Philadelphia",  quarter: "Q1",  value: 100098.0 }
    { model: "Small",  market: "Philadelphia",  quarter: "Q2",  value: 47251.0 }
    { model: "Small",  market: "Philadelphia",  quarter: "Q3",  value: 117404.0 }
    { model: "Small",  market: "Cleveland", quarter: "Q1",  value: 38536.0 }
    { model: "Small",  market: "Cleveland", quarter: "Q2",  value: 149568.0 }
    { model: "Small",  market: "Cleveland", quarter: "Q3",  value: 61596.0 }
    { model: "Small",  market: "Chicago", quarter: "Q1",  value: 76773.0 }
    { model: "Small",  market: "Chicago", quarter: "Q2",  value: 94829.0 }
    { model: "Small",  market: "Chicago", quarter: "Q3",  value: 52161.0 }
    { model: "Small",  market: "Milwaukee", quarter: "Q1",  value: 104585.0 }
    { model: "Small",  market: "Milwaukee", quarter: "Q2",  value: 109731.0 }
    { model: "Small",  market: "Milwaukee", quarter: "Q3",  value: 97999.0 }
    { model: "Small",  market: "Houston", quarter: "Q1",  value: 113503.0 }
    { model: "Small",  market: "Houston", quarter: "Q2",  value: 45711.0 }
    { model: "Small",  market: "Houston", quarter: "Q3",  value: 126919.0 }
    { model: "Small",  market: "Dallas", quarter: "Q1",  value: 140945.0 }
    { model: "Small",  market: "Dallas", quarter: "Q2",  value: 59309.0 }
    { model: "Small",  market: "Dallas", quarter: "Q3",  value: 34965.0 }
    { model: "Small",  market: "Austin", quarter: "Q1",  value: 64428.0 }
    { model: "Small",  market: "Austin", quarter: "Q2",  value: 78201.0 }
    { model: "Small",  market: "Austin", quarter: "Q3",  value: 116905.0 }
    { model: "Small",  market: "Seattle", quarter: "Q1",  value: 140135.0 }
    { model: "Small",  market: "Seattle", quarter: "Q2",  value: 88710.0 }
    { model: "Small",  market: "Seattle", quarter: "Q3",  value: 79771.0 }
    { model: "Small",  market: "San Francisco",  quarter: "Q1",  value: 67295.0 }
    { model: "Small",  market: "San Francisco",  quarter: "Q2",  value: 53376.0 }
    { model: "Small",  market: "San Francisco",  quarter: "Q3",  value: 37238.0 }
    { model: "Small",  market: "Los Angeles", quarter: "Q1",  value: 58400.0 }
    { model: "Small",  market: "Los Angeles", quarter: "Q2",  value: 98389.0 }
    { model: "Small",  market: "Los Angeles", quarter: "Q3",  value: 69750.0 }
    { model: "Medium",  market: "New York", quarter: "Q1",  value: 126176.0 }
    { model: "Medium",  market: "New York", quarter: "Q2",  value: 126209.0 }
    { model: "Medium",  market: "New York", quarter: "Q3",  value: 118290.0 }
    { model: "Medium",  market: "Boston", quarter: "Q1",  value: 67698.0 }
    { model: "Medium",  market: "Boston", quarter: "Q2",  value: 30344.0 }
    { model: "Medium",  market: "Boston", quarter: "Q3",  value: 63422.0 }
    { model: "Medium",  market: "Philadelphia",  quarter: "Q1",  value: 98031.0 }
    { model: "Medium",  market: "Philadelphia",  quarter: "Q2",  value: 57916.0 }
    { model: "Medium",  market: "Philadelphia",  quarter: "Q3",  value: 80330.0 }
    { model: "Medium",  market: "Cleveland", quarter: "Q1",  value: 41539.0 }
    { model: "Medium",  market: "Cleveland", quarter: "Q2",  value: 109826.0 }
    { model: "Medium",  market: "Cleveland", quarter: "Q3",  value: 139315.0 }
    { model: "Medium",  market: "Chicago", quarter: "Q1",  value: 68238.0 }
    { model: "Medium",  market: "Chicago", quarter: "Q2",  value: 48589.0 }
    { model: "Medium",  market: "Chicago", quarter: "Q3",  value: 134258.0 }
    { model: "Medium",  market: "Milwaukee", quarter: "Q1",  value: 132794.0 }
    { model: "Medium",  market: "Milwaukee", quarter: "Q2",  value: 93632.0 }
    { model: "Medium",  market: "Milwaukee", quarter: "Q3",  value: 114358.0 }
    { model: "Medium",  market: "Houston", quarter: "Q1",  value: 40775.0 }
    { model: "Medium",  market: "Houston", quarter: "Q2",  value: 52405.0 }
    { model: "Medium",  market: "Houston", quarter: "Q3",  value: 110234.0 }
    { model: "Medium",  market: "Dallas", quarter: "Q1",  value: 119919.0 }
    { model: "Medium",  market: "Dallas", quarter: "Q2",  value: 47503.0 }
    { model: "Medium",  market: "Dallas", quarter: "Q3",  value: 30906.0 }
    { model: "Medium",  market: "Austin", quarter: "Q1",  value: 75445.0 }
    { model: "Medium",  market: "Austin", quarter: "Q2",  value: 33031.0 }
    { model: "Medium",  market: "Austin", quarter: "Q3",  value: 136560.0 }
    { model: "Medium",  market: "Seattle", quarter: "Q1",  value: 53439.0 }
    { model: "Medium",  market: "Seattle", quarter: "Q2",  value: 76668.0 }
    { model: "Medium",  market: "Seattle", quarter: "Q3",  value: 125811.0 }
    { model: "Medium",  market: "San Francisco",  quarter: "Q1",  value: 79703.0 }
    { model: "Medium",  market: "San Francisco",  quarter: "Q2",  value: 30303.0 }
    { model: "Medium",  market: "San Francisco",  quarter: "Q3",  value: 51784.0 }
    { model: "Medium",  market: "Los Angeles", quarter: "Q1",  value: 39370.0 }
    { model: "Medium",  market: "Los Angeles", quarter: "Q2",  value: 98352.0 }
    { model: "Medium",  market: "Los Angeles", quarter: "Q3",  value: 80282.0 }
    { model: "Big",  market: "New York", quarter: "Q1",  value: 48421.0 }
    { model: "Big",  market: "New York", quarter: "Q2",  value: 125106.0 }
    { model: "Big",  market: "New York", quarter: "Q3",  value: 128461.0 }
    { model: "Big",  market: "Boston", quarter: "Q1",  value: 37520.0 }
    { model: "Big",  market: "Boston", quarter: "Q2",  value: 147042.0 }
    { model: "Big",  market: "Boston", quarter: "Q3",  value: 139006.0 }
    { model: "Big",  market: "Philadelphia",  quarter: "Q1",  value: 115971.0 }
    { model: "Big",  market: "Philadelphia",  quarter: "Q2",  value: 89524.0 }
    { model: "Big",  market: "Philadelphia",  quarter: "Q3",  value: 71961.0 }
    { model: "Big",  market: "Cleveland", quarter: "Q1",  value: 31989.0 }
    { model: "Big",  market: "Cleveland", quarter: "Q2",  value: 122645.0 }
    { model: "Big",  market: "Cleveland", quarter: "Q3",  value: 114414.0 }
    { model: "Big",  market: "Chicago", quarter: "Q1",  value: 86612.0 }
    { model: "Big",  market: "Chicago", quarter: "Q2",  value: 132626.0 }
    { model: "Big",  market: "Chicago", quarter: "Q3",  value: 109868.0 }
    { model: "Big",  market: "Milwaukee", quarter: "Q1",  value: 44468.0 }
    { model: "Big",  market: "Milwaukee", quarter: "Q2",  value: 67306.0 }
    { model: "Big",  market: "Milwaukee", quarter: "Q3",  value: 55322.0 }
    { model: "Big",  market: "Houston", quarter: "Q1",  value: 129861.0 }
    { model: "Big",  market: "Houston", quarter: "Q2",  value: 46381.0 }
    { model: "Big",  market: "Houston", quarter: "Q3",  value: 38456.0 }
    { model: "Big",  market: "Dallas", quarter: "Q1",  value: 129448.0 }
    { model: "Big",  market: "Dallas", quarter: "Q2",  value: 48762.0 }
    { model: "Big",  market: "Dallas", quarter: "Q3",  value: 77260.0 }
    { model: "Big",  market: "Austin", quarter: "Q1",  value: 142939.0 }
    { model: "Big",  market: "Austin", quarter: "Q2",  value: 35747.0 }
    { model: "Big",  market: "Austin", quarter: "Q3",  value: 41832.0 }
    { model: "Big",  market: "Seattle", quarter: "Q1",  value: 65549.0 }
    { model: "Big",  market: "Seattle", quarter: "Q2",  value: 44048.0 }
    { model: "Big",  market: "Seattle", quarter: "Q3",  value: 30966.0 }
    { model: "Big",  market: "San Francisco",  quarter: "Q1",  value: 31612.0 }
    { model: "Big",  market: "San Francisco",  quarter: "Q2",  value: 134963.0 }
    { model: "Big",  market: "San Francisco",  quarter: "Q3",  value: 85777.0 }
    { model: "Big",  market: "Los Angeles", quarter: "Q1",  value: 90179.0 }
    { model: "Big",  market: "Los Angeles", quarter: "Q2",  value: 88334.0 }
    { model: "Big",  market: "Los Angeles", quarter: "Q3",  value: 115008.0 }
  ]

  simpleSankeyData: [
    { head: "Total Revenue", tail: "Individual income taxes", billions: 1100  }
    { head: "Total Revenue", tail: "Corporate income taxes", billions: 249 }
    { head: "Total Revenue", tail: "Social Security/Payroll taxes", billions: 939 }
    { head: "Total Revenue", tail: "Excise taxes", billions: 78 }
    { head: "Total Revenue", tail: "Estate and gift taxes", billions: 20 }
    { head: "Total Revenue", tail: "Customs duties", billions: 24 }
    { head: "Total Revenue", tail: "Other", billions: 38 }
    { head: "Total Spending", tail: "Total Revenue", billions: 2400 }
    { head: "Total Spending", tail: "Deficit", billions: 1200 }
    { head: "Defense", tail: "Total Spending", billions: 728 }
    { head: "Other discretionary", tail: "Total Spending", billions: 675 }
    { head: "Social Security", tail: "Total Spending", billions: 695 }
    { head: "Medicare", tail: "Total Spending", billions: 453 }
    { head: "Medicaid", tail: "Total Spending", billions: 290 }
    { head: "Other Mandatory", tail: "Total Spending", billions: 575 }
    { head: "Interest on debt", tail: "Total Spending", billions: 178 }
    { head: "Potentional disaster costs", tail: "Total Spending", billions: 11 }
  ]

  balancedSankeyData: [
    { id: "Clip 1", count: 100 }
    { id: "Clip 2", count: 30 }
    { id: "Clip 3", count: 60 }
    { id: "Clip 4", count: 5 }
    { id: "Clip 5", count: 25 }
    { id: "Clip 6", count: 40 }
    { id: "Clip 7", count: 10 }
    { id: "Clip 8", count: 30 }
    { id: "Clip 9", count: 12 }
    { id: "Clip 10", count: 9 }
    { head: "Clip 1", tail: "Clip 10", count: 1 }
    { head: "Clip 1", tail: "Clip 6",  count: 10 }
    { head: "Clip 2", tail: "Clip 1",  count: 30 }
    { head: "Clip 3", tail: "Clip 1",  count: 60 }
    { head: "Clip 4", tail: "Clip 1",  count: 5 }
    { head: "Clip 5", tail: "Clip 2",  count: 20 }
    { head: "Clip 6", tail: "Clip 3",  count: 35 }
    { head: "Clip 6", tail: "Clip 4",  count: 5 }
    { head: "Clip 7", tail: "Clip 5",  count: 8 }
    { head: "Clip 8", tail: "Clip 5",  count: 5 }
    { head: "Clip 8", tail: "Clip 3",  count: 5 }
    { head: "Clip 8", tail: "Clip 10", count: 4 }
    { head: "Clip 9", tail: "Clip 8",  count: 10 }
    { head: "Clip 10", tail: "Clip 8",  count: 1 }
    { head: "Clip 10", tail: "Clip 9",  count: 5 }
    { head: "Clip 10", tail: "Clip 7",  count: 3 }
  ]

  simpleBarData: [
    { country: "USA", count: 226710 }
    { country: "UK", count: 56990 }
    { country: "Canada", count: 19700 }
    { country: "Australia", count: 15316 }
    { country: "Other", count: 18581 }
  ]

  multipleBarData: [
    { age: "0-14", gender: "male", count:  32107900 }
    { age: "0-14", gender: "female", count:  30781823 }
    { age: "15-64", gender: "male", count: 104411352 }
    { age: "15-64", gender: "female", count: 104808064 }
    { age: "65-over", gender: "male", count:  17745363 }
    { age: "65-over", gender: "female", count:  23377542 }
  ]

  barPercentData: [
    { country: "China, Mainland", date: "2010/10", value: 1175.3 }
    { country: "China, Mainland", date: "2010/11", value: 1164.1 }
    { country: "China, Mainland", date: "2010/12", value: 1160.1 }
    { country: "China, Mainland", date: "2011/01", value: 1154.7 }
    { country: "China, Mainland", date: "2011/02", value: 1154.1 }
    { country: "China, Mainland", date: "2011/03", value: 1144.9 }
    { country: "China, Mainland", date: "2011/04", value: 1152.5 }
    { country: "China, Mainland", date: "2011/05", value: 1159.8 }
    { country: "China, Mainland", date: "2011/06", value: 1165.5 }
    { country: "China, Mainland", date: "2011/07", value: 1173.5 }
    { country: "China, Mainland", date: "2011/08", value: 1137 }
    { country: "China, Mainland", date: "2011/09", value: 1148.3 }
    { country: "China, Mainland", date: "2011/10", value: 1134.1 }
    { country: "Japan", date: "2010/10", value: 873.6 }
    { country: "Japan", date: "2010/11", value: 875.9 }
    { country: "Japan", date: "2010/12", value: 882.3 }
    { country: "Japan", date: "2011/01", value: 885.9 }
    { country: "Japan", date: "2011/02", value: 890.3 }
    { country: "Japan", date: "2011/03", value: 907.9 }
    { country: "Japan", date: "2011/04", value: 906.9 }
    { country: "Japan", date: "2011/05", value: 912.4 }
    { country: "Japan", date: "2011/06", value: 911 }
    { country: "Japan", date: "2011/07", value: 914.8 }
    { country: "Japan", date: "2011/08", value: 936.6 }
    { country: "Japan", date: "2011/09", value: 956.8 }
    { country: "Japan", date: "2011/10", value: 979 }
    { country: "United Kingdom", date: "2010/10", value: 209 }
    { country: "United Kingdom", date: "2010/11", value: 242.5 }
    { country: "United Kingdom", date: "2010/12", value: 270.4 }
    { country: "United Kingdom", date: "2011/01", value: 278.1 }
    { country: "United Kingdom", date: "2011/02", value: 295.7 }
    { country: "United Kingdom", date: "2011/03", value: 324.6 }
    { country: "United Kingdom", date: "2011/04", value: 332.5 }
    { country: "United Kingdom", date: "2011/05", value: 345.1 }
    { country: "United Kingdom", date: "2011/06", value: 347.8 }
    { country: "United Kingdom", date: "2011/07", value: 353.4 }
    { country: "United Kingdom", date: "2011/08", value: 397.2 }
    { country: "United Kingdom", date: "2011/09", value: 421.6 }
    { country: "United Kingdom", date: "2011/10", value: 408.4 }
    { country: "Oil Exporters", date: "2010/10", value: 207.8 }
    { country: "Oil Exporters", date: "2010/11", value: 204.3 }
    { country: "Oil Exporters", date: "2010/12", value: 211.9 }
    { country: "Oil Exporters", date: "2011/01", value: 215.5 }
    { country: "Oil Exporters", date: "2011/02", value: 218.8 }
    { country: "Oil Exporters", date: "2011/03", value: 222.3 }
    { country: "Oil Exporters", date: "2011/04", value: 221.5 }
    { country: "Oil Exporters", date: "2011/05", value: 230 }
    { country: "Oil Exporters", date: "2011/06", value: 229.7 }
    { country: "Oil Exporters", date: "2011/07", value: 234.4 }
    { country: "Oil Exporters", date: "2011/08", value: 236.3 }
    { country: "Oil Exporters", date: "2011/09", value: 229.9 }
    { country: "Oil Exporters", date: "2011/10", value: 226.2 }
    { country: "Brazil", date: "2010/10", value: 183 }
    { country: "Brazil", date: "2010/11", value: 189.8 }
    { country: "Brazil", date: "2010/12", value: 186.1 }
    { country: "Brazil", date: "2011/01", value: 197.6 }
    { country: "Brazil", date: "2011/02", value: 194.3 }
    { country: "Brazil", date: "2011/03", value: 193.5 }
    { country: "Brazil", date: "2011/04", value: 206.9 }
    { country: "Brazil", date: "2011/05", value: 211.4 }
    { country: "Brazil", date: "2011/06", value: 207.1 }
    { country: "Brazil", date: "2011/07", value: 210 }
    { country: "Brazil", date: "2011/08", value: 210 }
    { country: "Brazil", date: "2011/09", value: 206.2 }
    { country: "Brazil", date: "2011/10", value: 209.1 }
    { country: "Carib Bnkng Ctrs", date: "2010/10", value: 146.3 }
    { country: "Carib Bnkng Ctrs", date: "2010/11", value: 158.8 }
    { country: "Carib Bnkng Ctrs", date: "2010/12", value: 168.4 }
    { country: "Carib Bnkng Ctrs", date: "2011/01", value: 166.9 }
    { country: "Carib Bnkng Ctrs", date: "2011/02", value: 169.8 }
    { country: "Carib Bnkng Ctrs", date: "2011/03", value: 155.2 }
    { country: "Carib Bnkng Ctrs", date: "2011/04", value: 139.8 }
    { country: "Carib Bnkng Ctrs", date: "2011/05", value: 152.6 }
    { country: "Carib Bnkng Ctrs", date: "2011/06", value: 145.5 }
    { country: "Carib Bnkng Ctrs", date: "2011/07", value: 128.7 }
    { country: "Carib Bnkng Ctrs", date: "2011/08", value: 161.2 }
    { country: "Carib Bnkng Ctrs", date: "2011/09", value: 172.9 }
    { country: "Carib Bnkng Ctrs", date: "2011/10", value: 175.2 }
    { country: "Taiwan", date: "2010/10", value: 154.5 }
    { country: "Taiwan", date: "2010/11", value: 154.4 }
    { country: "Taiwan", date: "2010/12", value: 155.1 }
    { country: "Taiwan", date: "2011/01", value: 157.2 }
    { country: "Taiwan", date: "2011/02", value: 155.9 }
    { country: "Taiwan", date: "2011/03", value: 156.1 }
    { country: "Taiwan", date: "2011/04", value: 154.5 }
    { country: "Taiwan", date: "2011/05", value: 153.4 }
    { country: "Taiwan", date: "2011/06", value: 153.4 }
    { country: "Taiwan", date: "2011/07", value: 154.3 }
    { country: "Taiwan", date: "2011/08", value: 150.3 }
    { country: "Taiwan", date: "2011/09", value: 149.3 }
    { country: "Taiwan", date: "2011/10", value: 150.1 }
    { country: "Switzerland", date: "2010/10", value: 107.6 }
    { country: "Switzerland", date: "2010/11", value: 106.8 }
    { country: "Switzerland", date: "2010/12", value: 106.8 }
    { country: "Switzerland", date: "2011/01", value: 107.4 }
    { country: "Switzerland", date: "2011/02", value: 109.6 }
    { country: "Switzerland", date: "2011/03", value: 109.7 }
    { country: "Switzerland", date: "2011/04", value: 106.1 }
    { country: "Switzerland", date: "2011/05", value: 108 }
    { country: "Switzerland", date: "2011/06", value: 108 }
    { country: "Switzerland", date: "2011/07", value: 108.4 }
    { country: "Switzerland", date: "2011/08", value: 147.5 }
    { country: "Switzerland", date: "2011/09", value: 146.1 }
    { country: "Switzerland", date: "2011/10", value: 131.7 }
    { country: "Hong Kong", date: "2010/10", value: 135.2 }
    { country: "Hong Kong", date: "2010/11", value: 134.9 }
    { country: "Hong Kong", date: "2010/12", value: 134.2 }
    { country: "Hong Kong", date: "2011/01", value: 128.1 }
    { country: "Hong Kong", date: "2011/02", value: 124.6 }
    { country: "Hong Kong", date: "2011/03", value: 122.1 }
    { country: "Hong Kong", date: "2011/04", value: 122.4 }
    { country: "Hong Kong", date: "2011/05", value: 122 }
    { country: "Hong Kong", date: "2011/06", value: 118.4 }
    { country: "Hong Kong", date: "2011/07", value: 111.9 }
    { country: "Hong Kong", date: "2011/08", value: 107.9 }
    { country: "Hong Kong", date: "2011/09", value: 109 }
    { country: "Hong Kong", date: "2011/10", value: 110.7 }
    { country: "Russia", date: "2010/10", value: 176.3 }
    { country: "Russia", date: "2010/11", value: 167.3 }
    { country: "Russia", date: "2010/12", value: 151 }
    { country: "Russia", date: "2011/01", value: 139.3 }
    { country: "Russia", date: "2011/02", value: 130.5 }
    { country: "Russia", date: "2011/03", value: 127.8 }
    { country: "Russia", date: "2011/04", value: 125.4 }
    { country: "Russia", date: "2011/05", value: 115.2 }
    { country: "Russia", date: "2011/06", value: 110.7 }
    { country: "Russia", date: "2011/07", value: 100.7 }
    { country: "Russia", date: "2011/08", value: 97.1 }
    { country: "Russia", date: "2011/09", value: 94.6 }
    { country: "Russia", date: "2011/10", value: 92.1 }
    { country: "Canada", date: "2010/10", value: 66.1 }
    { country: "Canada", date: "2010/11", value: 75.6 }
    { country: "Canada", date: "2010/12", value: 75.3 }
    { country: "Canada", date: "2011/01", value: 84.3 }
    { country: "Canada", date: "2011/02", value: 90 }
    { country: "Canada", date: "2011/03", value: 90.3 }
    { country: "Canada", date: "2011/04", value: 85 }
    { country: "Canada", date: "2011/05", value: 87.8 }
    { country: "Canada", date: "2011/06", value: 81.4 }
    { country: "Canada", date: "2011/07", value: 83.5 }
    { country: "Canada", date: "2011/08", value: 82.6 }
    { country: "Canada", date: "2011/09", value: 84.8 }
    { country: "Canada", date: "2011/10", value: 81.8 }
    { country: "Luxembourg", date: "2010/10", value: 78.5 }
    { country: "Luxembourg", date: "2010/11", value: 81.9 }
    { country: "Luxembourg", date: "2010/12", value: 86.4 }
    { country: "Luxembourg", date: "2011/01", value: 83 }
    { country: "Luxembourg", date: "2011/02", value: 81 }
    { country: "Luxembourg", date: "2011/03", value: 81.1 }
    { country: "Luxembourg", date: "2011/04", value: 78.4 }
    { country: "Luxembourg", date: "2011/05", value: 68.1 }
    { country: "Luxembourg", date: "2011/06", value: 69 }
    { country: "Luxembourg", date: "2011/07", value: 61.4 }
    { country: "Luxembourg", date: "2011/08", value: 62 }
    { country: "Luxembourg", date: "2011/09", value: 73.7 }
    { country: "Luxembourg", date: "2011/10", value: 72.3 }
    { country: "Singapore", date: "2010/10", value: 66.4 }
    { country: "Singapore", date: "2010/11", value: 62.2 }
    { country: "Singapore", date: "2010/12", value: 72.9 }
    { country: "Singapore", date: "2011/01", value: 57.8 }
    { country: "Singapore", date: "2011/02", value: 66.7 }
    { country: "Singapore", date: "2011/03", value: 55.7 }
    { country: "Singapore", date: "2011/04", value: 60.3 }
    { country: "Singapore", date: "2011/05", value: 57.5 }
    { country: "Singapore", date: "2011/06", value: 61.7 }
    { country: "Singapore", date: "2011/07", value: 63 }
    { country: "Singapore", date: "2011/08", value: 58.3 }
    { country: "Singapore", date: "2011/09", value: 63.5 }
    { country: "Singapore", date: "2011/10", value: 63.7 }
    { country: "Germany", date: "2010/10", value: 58.2 }
    { country: "Germany", date: "2010/11", value: 58.6 }
    { country: "Germany", date: "2010/12", value: 60.5 }
    { country: "Germany", date: "2011/01", value: 61.1 }
    { country: "Germany", date: "2011/02", value: 58.3 }
    { country: "Germany", date: "2011/03", value: 59.8 }
    { country: "Germany", date: "2011/04", value: 61.3 }
    { country: "Germany", date: "2011/05", value: 61.2 }
    { country: "Germany", date: "2011/06", value: 62 }
    { country: "Germany", date: "2011/07", value: 61.2 }
    { country: "Germany", date: "2011/08", value: 60.2 }
    { country: "Germany", date: "2011/09", value: 58.9 }
    { country: "Germany", date: "2011/10", value: 60.9 }
    { country: "Thailand", date: "2010/10", value: 52.7 }
    { country: "Thailand", date: "2010/11", value: 52.2 }
    { country: "Thailand", date: "2010/12", value: 52 }
    { country: "Thailand", date: "2011/01", value: 56.5 }
    { country: "Thailand", date: "2011/02", value: 57.6 }
    { country: "Thailand", date: "2011/03", value: 57.1 }
    { country: "Thailand", date: "2011/04", value: 60.7 }
    { country: "Thailand", date: "2011/05", value: 59.8 }
    { country: "Thailand", date: "2011/06", value: 62.6 }
    { country: "Thailand", date: "2011/07", value: 65.2 }
    { country: "Thailand", date: "2011/08", value: 54.5 }
    { country: "Thailand", date: "2011/09", value: 55 }
    { country: "Thailand", date: "2011/10", value: 55.9 }
    { country: "France", date: "2010/10", value: 23.5 }
    { country: "France", date: "2010/11", value: 20.1 }
    { country: "France", date: "2010/12", value: 15 }
    { country: "France", date: "2011/01", value: 30.2 }
    { country: "France", date: "2011/02", value: 30.2 }
    { country: "France", date: "2011/03", value: 17.7 }
    { country: "France", date: "2011/04", value: 20.3 }
    { country: "France", date: "2011/05", value: 23.6 }
    { country: "France", date: "2011/06", value: 22.4 }
    { country: "France", date: "2011/07", value: 22.5 }
    { country: "France", date: "2011/08", value: 29 }
    { country: "France", date: "2011/09", value: 43.9 }
    { country: "France", date: "2011/10", value: 48 }
    { country: "Turkey", date: "2010/10", value: 27.8 }
    { country: "Turkey", date: "2010/11", value: 29.1 }
    { country: "Turkey", date: "2010/12", value: 28.9 }
    { country: "Turkey", date: "2011/01", value: 32.9 }
    { country: "Turkey", date: "2011/02", value: 34.3 }
    { country: "Turkey", date: "2011/03", value: 36.2 }
    { country: "Turkey", date: "2011/04", value: 37.9 }
    { country: "Turkey", date: "2011/05", value: 39.3 }
    { country: "Turkey", date: "2011/06", value: 41.9 }
    { country: "Turkey", date: "2011/07", value: 41.9 }
    { country: "Turkey", date: "2011/08", value: 39.2 }
    { country: "Turkey", date: "2011/09", value: 39.9 }
    { country: "Turkey", date: "2011/10", value: 39.7 }
    { country: "Ireland", date: "2010/10", value: 48.9 }
    { country: "Ireland", date: "2010/11", value: 50 }
    { country: "Ireland", date: "2010/12", value: 45.8 }
    { country: "Ireland", date: "2011/01", value: 44.4 }
    { country: "Ireland", date: "2011/02", value: 42 }
    { country: "Ireland", date: "2011/03", value: 44 }
    { country: "Ireland", date: "2011/04", value: 40.2 }
    { country: "Ireland", date: "2011/05", value: 33.5 }
    { country: "Ireland", date: "2011/06", value: 36.1 }
    { country: "Ireland", date: "2011/07", value: 34.3 }
    { country: "Ireland", date: "2011/08", value: 33.6 }
    { country: "Ireland", date: "2011/09", value: 34 }
    { country: "Ireland", date: "2011/10", value: 37.9 }
    { country: "Korea, South", date: "2010/10", value: 39.4 }
    { country: "Korea, South", date: "2010/11", value: 39.8 }
    { country: "Korea, South", date: "2010/12", value: 36.2 }
    { country: "Korea, South", date: "2011/01", value: 31.9 }
    { country: "Korea, South", date: "2011/02", value: 31.2 }
    { country: "Korea, South", date: "2011/03", value: 32.5 }
    { country: "Korea, South", date: "2011/04", value: 30.8 }
    { country: "Korea, South", date: "2011/05", value: 32.5 }
    { country: "Korea, South", date: "2011/06", value: 29.9 }
    { country: "Korea, South", date: "2011/07", value: 29.4 }
    { country: "Korea, South", date: "2011/08", value: 32.4 }
    { country: "Korea, South", date: "2011/09", value: 33.6 }
    { country: "Korea, South", date: "2011/10", value: 37.8 }
    { country: "Belgium", date: "2010/10", value: 33.4 }
    { country: "Belgium", date: "2010/11", value: 33.4 }
    { country: "Belgium", date: "2010/12", value: 33.2 }
    { country: "Belgium", date: "2011/01", value: 32.1 }
    { country: "Belgium", date: "2011/02", value: 32 }
    { country: "Belgium", date: "2011/03", value: 32.2 }
    { country: "Belgium", date: "2011/04", value: 31.6 }
    { country: "Belgium", date: "2011/05", value: 31.4 }
    { country: "Belgium", date: "2011/06", value: 33.6 }
    { country: "Belgium", date: "2011/07", value: 31.3 }
    { country: "Belgium", date: "2011/08", value: 31.8 }
    { country: "Belgium", date: "2011/09", value: 35.8 }
    { country: "Belgium", date: "2011/10", value: 36.1 }
    { country: "India", date: "2010/10", value: 40.1 }
    { country: "India", date: "2010/11", value: 39.7 }
    { country: "India", date: "2010/12", value: 40.5 }
    { country: "India", date: "2011/01", value: 40.6 }
    { country: "India", date: "2011/02", value: 40.3 }
    { country: "India", date: "2011/03", value: 39.8 }
    { country: "India", date: "2011/04", value: 42.1 }
    { country: "India", date: "2011/05", value: 41 }
    { country: "India", date: "2011/06", value: 38.9 }
    { country: "India", date: "2011/07", value: 37.9 }
    { country: "India", date: "2011/08", value: 37.7 }
    { country: "India", date: "2011/09", value: 36.5 }
    { country: "India", date: "2011/10", value: 35.5 }
    { country: "Mexico", date: "2010/10", value: 34.8 }
    { country: "Mexico", date: "2010/11", value: 32.6 }
    { country: "Mexico", date: "2010/12", value: 33.6 }
    { country: "Mexico", date: "2011/01", value: 34.4 }
    { country: "Mexico", date: "2011/02", value: 34.6 }
    { country: "Mexico", date: "2011/03", value: 28.1 }
    { country: "Mexico", date: "2011/04", value: 26.7 }
    { country: "Mexico", date: "2011/05", value: 27.7 }
    { country: "Mexico", date: "2011/06", value: 29.2 }
    { country: "Mexico", date: "2011/07", value: 29.1 }
    { country: "Mexico", date: "2011/08", value: 28 }
    { country: "Mexico", date: "2011/09", value: 27.1 }
    { country: "Mexico", date: "2011/10", value: 26.8 }
    { country: "Poland", date: "2010/10", value: 28.8 }
    { country: "Poland", date: "2010/11", value: 27.2 }
    { country: "Poland", date: "2010/12", value: 25.5 }
    { country: "Poland", date: "2011/01", value: 26.3 }
    { country: "Poland", date: "2011/02", value: 27.3 }
    { country: "Poland", date: "2011/03", value: 28.4 }
    { country: "Poland", date: "2011/04", value: 27.4 }
    { country: "Poland", date: "2011/05", value: 27.9 }
    { country: "Poland", date: "2011/06", value: 28.5 }
    { country: "Poland", date: "2011/07", value: 29.3 }
    { country: "Poland", date: "2011/08", value: 28.7 }
    { country: "Poland", date: "2011/09", value: 27.1 }
    { country: "Poland", date: "2011/10", value: 26.1 }
    { country: "Philippines", date: "2010/10", value: 18.5 }
    { country: "Philippines", date: "2010/11", value: 19.2 }
    { country: "Philippines", date: "2010/12", value: 20.1 }
    { country: "Philippines", date: "2011/01", value: 22.8 }
    { country: "Philippines", date: "2011/02", value: 22.7 }
    { country: "Philippines", date: "2011/03", value: 23.4 }
    { country: "Philippines", date: "2011/04", value: 24.1 }
    { country: "Philippines", date: "2011/05", value: 23.8 }
    { country: "Philippines", date: "2011/06", value: 22.7 }
    { country: "Philippines", date: "2011/07", value: 25.1 }
    { country: "Philippines", date: "2011/08", value: 25.1 }
    { country: "Philippines", date: "2011/09", value: 25.5 }
    { country: "Philippines", date: "2011/10", value: 25.5 }
    { country: "Italy", date: "2010/10", value: 23.7 }
    { country: "Italy", date: "2010/11", value: 23.6 }
    { country: "Italy", date: "2010/12", value: 23.7 }
    { country: "Italy", date: "2011/01", value: 24.6 }
    { country: "Italy", date: "2011/02", value: 24.3 }
    { country: "Italy", date: "2011/03", value: 24.2 }
    { country: "Italy", date: "2011/04", value: 24.8 }
    { country: "Italy", date: "2011/05", value: 25.4 }
    { country: "Italy", date: "2011/06", value: 23.7 }
    { country: "Italy", date: "2011/07", value: 24.3 }
    { country: "Italy", date: "2011/08", value: 23.7 }
    { country: "Italy", date: "2011/09", value: 24.4 }
    { country: "Italy", date: "2011/10", value: 24.2 }
    { country: "Netherlands", date: "2010/10", value: 22 }
    { country: "Netherlands", date: "2010/11", value: 22.1 }
    { country: "Netherlands", date: "2010/12", value: 22.7 }
    { country: "Netherlands", date: "2011/01", value: 25.4 }
    { country: "Netherlands", date: "2011/02", value: 24.9 }
    { country: "Netherlands", date: "2011/03", value: 25.1 }
    { country: "Netherlands", date: "2011/04", value: 23.6 }
    { country: "Netherlands", date: "2011/05", value: 23.7 }
    { country: "Netherlands", date: "2011/06", value: 23.5 }
    { country: "Netherlands", date: "2011/07", value: 23.2 }
    { country: "Netherlands", date: "2011/08", value: 22.6 }
    { country: "Netherlands", date: "2011/09", value: 23.4 }
    { country: "Netherlands", date: "2011/10", value: 22.5 }
    { country: "Colombia", date: "2010/10", value: 16.7 }
    { country: "Colombia", date: "2010/11", value: 20.3 }
    { country: "Colombia", date: "2010/12", value: 20.2 }
    { country: "Colombia", date: "2011/01", value: 19.8 }
    { country: "Colombia", date: "2011/02", value: 20.1 }
    { country: "Colombia", date: "2011/03", value: 20.2 }
    { country: "Colombia", date: "2011/04", value: 19.8 }
    { country: "Colombia", date: "2011/05", value: 19.9 }
    { country: "Colombia", date: "2011/06", value: 20.1 }
    { country: "Colombia", date: "2011/07", value: 20 }
    { country: "Colombia", date: "2011/08", value: 21 }
    { country: "Colombia", date: "2011/09", value: 21.3 }
    { country: "Colombia", date: "2011/10", value: 21.7 }
    { country: "Sweden", date: "2010/10", value: 16.1 }
    { country: "Sweden", date: "2010/11", value: 15.2 }
    { country: "Sweden", date: "2010/12", value: 16.8 }
    { country: "Sweden", date: "2011/01", value: 17 }
    { country: "Sweden", date: "2011/02", value: 17.7 }
    { country: "Sweden", date: "2011/03", value: 21.3 }
    { country: "Sweden", date: "2011/04", value: 21.4 }
    { country: "Sweden", date: "2011/05", value: 20.9 }
    { country: "Sweden", date: "2011/06", value: 21.3 }
    { country: "Sweden", date: "2011/07", value: 21.3 }
    { country: "Sweden", date: "2011/08", value: 21.3 }
    { country: "Sweden", date: "2011/09", value: 21.6 }
    { country: "Sweden", date: "2011/10", value: 21.5 }
    { country: "Chile", date: "2010/10", value: 13.4 }
    { country: "Chile", date: "2010/11", value: 13.4 }
    { country: "Chile", date: "2010/12", value: 13.9 }
    { country: "Chile", date: "2011/01", value: 15 }
    { country: "Chile", date: "2011/02", value: 16 }
    { country: "Chile", date: "2011/03", value: 16.7 }
    { country: "Chile", date: "2011/04", value: 18.6 }
    { country: "Chile", date: "2011/05", value: 18.9 }
    { country: "Chile", date: "2011/06", value: 18.4 }
    { country: "Chile", date: "2011/07", value: 18 }
    { country: "Chile", date: "2011/08", value: 19.4 }
    { country: "Chile", date: "2011/09", value: 18.8 }
    { country: "Chile", date: "2011/10", value: 20.7 }
    { country: "Norway", date: "2010/10", value: 18 }
    { country: "Norway", date: "2010/11", value: 19 }
    { country: "Norway", date: "2010/12", value: 19.6 }
    { country: "Norway", date: "2011/01", value: 19.4 }
    { country: "Norway", date: "2011/02", value: 20.8 }
    { country: "Norway", date: "2011/03", value: 21.4 }
    { country: "Norway", date: "2011/04", value: 21.1 }
    { country: "Norway", date: "2011/05", value: 21.1 }
    { country: "Norway", date: "2011/06", value: 20.4 }
    { country: "Norway", date: "2011/07", value: 17.6 }
    { country: "Norway", date: "2011/08", value: 22 }
    { country: "Norway", date: "2011/09", value: 22.6 }
    { country: "Norway", date: "2011/10", value: 19.9 }
    { country: "Australia", date: "2010/10", value: 15.7 }
    { country: "Australia", date: "2010/11", value: 14.9 }
    { country: "Australia", date: "2010/12", value: 14.9 }
    { country: "Australia", date: "2011/01", value: 14.7 }
    { country: "Australia", date: "2011/02", value: 12.6 }
    { country: "Australia", date: "2011/03", value: 10.3 }
    { country: "Australia", date: "2011/04", value: 13.1 }
    { country: "Australia", date: "2011/05", value: 12.3 }
    { country: "Australia", date: "2011/06", value: 13.9 }
    { country: "Australia", date: "2011/07", value: 13.1 }
    { country: "Australia", date: "2011/08", value: 11.6 }
    { country: "Australia", date: "2011/09", value: 13.4 }
    { country: "Australia", date: "2011/10", value: 14.7 }
    { country: "Israel", date: "2010/10", value: 17.9 }
    { country: "Israel", date: "2010/11", value: 20.5 }
    { country: "Israel", date: "2010/12", value: 20.6 }
    { country: "Israel", date: "2011/01", value: 19.9 }
    { country: "Israel", date: "2011/02", value: 19.8 }
    { country: "Israel", date: "2011/03", value: 18.9 }
    { country: "Israel", date: "2011/04", value: 19.3 }
    { country: "Israel", date: "2011/05", value: 19.1 }
    { country: "Israel", date: "2011/06", value: 18.3 }
    { country: "Israel", date: "2011/07", value: 17.2 }
    { country: "Israel", date: "2011/08", value: 18.3 }
    { country: "Israel", date: "2011/09", value: 15.7 }
    { country: "Israel", date: "2011/10", value: 14.7 }
    { country: "Malaysia", date: "2010/10", value: 11.6 }
    { country: "Malaysia", date: "2010/11", value: 11.7 }
    { country: "Malaysia", date: "2010/12", value: 11.5 }
    { country: "Malaysia", date: "2011/01", value: 11.3 }
    { country: "Malaysia", date: "2011/02", value: 11.3 }
    { country: "Malaysia", date: "2011/03", value: 11.2 }
    { country: "Malaysia", date: "2011/04", value: 12.2 }
    { country: "Malaysia", date: "2011/05", value: 12.7 }
    { country: "Malaysia", date: "2011/06", value: 12 }
    { country: "Malaysia", date: "2011/07", value: 13.3 }
    { country: "Malaysia", date: "2011/08", value: 13.4 }
    { country: "Malaysia", date: "2011/09", value: 13.7 }
    { country: "Malaysia", date: "2011/10", value: 14.4 }
    { country: "All Other", date: "2010/10", value: 232.1 }
    { country: "All Other", date: "2010/11", value: 230.5 }
    { country: "All Other", date: "2010/12", value: 219.2 }
    { country: "All Other", date: "2011/01", value: 215.4 }
    { country: "All Other", date: "2011/02", value: 212.7 }
    { country: "All Other", date: "2011/03", value: 216.3 }
    { country: "All Other", date: "2011/04", value: 218.7 }
    { country: "All Other", date: "2011/05", value: 215.8 }
    { country: "All Other", date: "2011/06", value: 212.1 }
    { country: "All Other", date: "2011/07", value: 210.9 }
    { country: "All Other", date: "2011/08", value: 214.9 }
    { country: "All Other", date: "2011/09", value: 211.5 }
  ]

  lineDate: [
    { year: 1790, population: 3929214, area: 891364 }
    { year: 1800, population: 5308483, area: 891364 }
    { year: 1810, population: 7239881, area: 1722685 }
    { year: 1820, population: 9638453, area: 1792552 }
    { year: 1830, population: 12866020, area: 1792552 }
    { year: 1840, population: 17069453, area: 1792552 }
    { year: 1850, population: 23191876, area: 2991655 }
    { year: 1860, population: 31443321, area: 3021295 }
    { year: 1870, population: 39818449, area: 3612299 }
    { year: 1880, population: 50189209, area: 3612299 }
    { year: 1890, population: 62979766, area: 3612299 }
    { year: 1900, population: 76212168, area: 3618770 }
    { year: 1910, population: 92228496, area: 3618770 }
    { year: 1920, population: 106021537, area: 3618770 }
    { year: 1930, population: 123202624, area: 3618770 }
    { year: 1940, population: 132164569, area: 3618770 }
    { year: 1950, population: 151325798, area: 3618770 }
    { year: 1960, population: 179323175, area: 3618770 }
    { year: 1970, population: 203302031, area: 3618770 }
    { year: 1980, population: 226542199, area: 3618770 }
    { year: 1990, population: 248718302, area: 3717796 }
    { year: 2000, population: 281424603, area: 3794083 }
  ]

  geoData: [
    { country: "Afghanistan", code: "AFG", summers: 12, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Algeria", code: "DZA", summers: 11, summerGold: 4, summerSilver: 2, summerBronze: 8, summerTotal: 14,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Argentina", code: "ARG", summers: 22, summerGold: 17, summerSilver: 23, summerBronze: 26,
    summerTotal: 66, winters: 17, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 220, games: 221,
    golds: 222, silvers: 223, bronzes: 224, total: 225 },
    { country: "Armenia", code: "ARM", summers: 4, summerGold: 1, summerSilver: 1, summerBronze: 7, summerTotal: 9,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Australasia", code: "ANZ", summers: 2, summerGold: 3, summerSilver: 4, summerBronze: 5,
    summerTotal: 12, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 20, games: 21, golds: 22,
    silvers: 23, bronzes: 24, total: 25 },
    { country: "Australia", code: "AUS", summers: 24, summerGold: 131, summerSilver: 137, summerBronze: 164,
    summerTotal: 432, winters: 17, winterGold: 5, winterSilver: 1, winterBronze: 3, winterTotal: 240, games: 241,
    golds: 242, silvers: 243, bronzes: 244, total: 245 },
    { country: "Austria", code: "AUT", summers: 25, summerGold: 18, summerSilver: 33, summerBronze: 35, summerTotal: 86,
    winters: 21, winterGold: 55, winterSilver: 70, winterBronze: 76, winterTotal: 250, games: 251, golds: 252,
    silvers: 253, bronzes: 254, total: 255 },
    { country: "Azerbaijan", code: "AZE", summers: 4, summerGold: 4, summerSilver: 3, summerBronze: 9, summerTotal: 16,
    winters: 4, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Bahamas", code: "BHS", summers: 14, summerGold: 3, summerSilver: 3, summerBronze: 4, summerTotal: 10,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Barbados", code: "BRB", summers: 10, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Belarus", code: "BLR", summers: 4, summerGold: 10, summerSilver: 19, summerBronze: 35, summerTotal: 64,
    winters: 5, winterGold: 1, winterSilver: 4, winterBronze: 4, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Belgium", code: "BEL", summers: 24, summerGold: 37, summerSilver: 51, summerBronze: 51,
    summerTotal: 139, winters: 19, winterGold: 1, winterSilver: 1, winterBronze: 3, winterTotal: 240, games: 241,
    golds: 242, silvers: 243, bronzes: 244, total: 245 },
    { country: "Bermuda", code: "BMU", summers: 16, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 160, games: 161, golds: 162, silvers: 163,
    bronzes: 164, total: 165 },
    { country: "Bohemia", code: "BOH", summers: 3, summerGold: 0, summerSilver: 1, summerBronze: 3, summerTotal: 4,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 30, games: 31, golds: 32, silvers: 33,
    bronzes: 34, total: 35 },
    { country: "Brazil", code: "BRA", summers: 20, summerGold: 20, summerSilver: 25, summerBronze: 46, summerTotal: 91,
    winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 200, games: 201, golds: 202, silvers: 203,
    bronzes: 204, total: 205 },
    { country: "British West Indies", code: "IOT", summers: 1, summerGold: 0, summerSilver: 0, summerBronze: 2,
    summerTotal: 2, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 10, games: 11, golds: 12,
    silvers: 13, bronzes: 14, total: 15 },
    { country: "Bulgaria", code: "BGR", summers: 18, summerGold: 51, summerSilver: 84, summerBronze: 77,
    summerTotal: 212, winters: 18, winterGold: 1, winterSilver: 2, winterBronze: 3, winterTotal: 180, games: 181,
    golds: 182, silvers: 183, bronzes: 184, total: 185 },
    { country: "Burundi", code: "BDI", summers: 4, summerGold: 1, summerSilver: 0, summerBronze: 0, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Cameroon", code: "CMR", summers: 12, summerGold: 3, summerSilver: 1, summerBronze: 1, summerTotal: 5,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Canada", code: "CAN", summers: 24, summerGold: 58, summerSilver: 94, summerBronze: 108,
    summerTotal: 260, winters: 21, winterGold: 52, winterSilver: 45, winterBronze: 48, winterTotal: 240, games: 241,
    golds: 242, silvers: 243, bronzes: 244, total: 245 },
    { country: "Chile", code: "CHL", summers: 21, summerGold: 2, summerSilver: 7, summerBronze: 4, summerTotal: 13,
    winters: 15, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 210, games: 211, golds: 212,
    silvers: 213, bronzes: 214, total: 215 },
    { country: "China", code: "CHN", summers: 8, summerGold: 163, summerSilver: 117, summerBronze: 105,
    summerTotal: 385, winters: 9, winterGold: 9, winterSilver: 18, winterBronze: 17, winterTotal: 80, games: 81,
    golds: 82, silvers: 83, bronzes: 84, total: 85 },
    { country: "Chinese Taipei", code: "TPE", summers: 15, summerGold: 2, summerSilver: 6, summerBronze: 11,
    summerTotal: 19, winters: 10, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151,
    golds: 152, silvers: 153, bronzes: 154, total: 155 },
    { country: "Colombia", code: "COL", summers: 17, summerGold: 1, summerSilver: 3, summerBronze: 7, summerTotal: 11,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 170, games: 171, golds: 172, silvers: 173,
    bronzes: 174, total: 175 },
    { country: "Costa Rica", code: "CRI", summers: 13, summerGold: 1, summerSilver: 1, summerBronze: 2, summerTotal: 4,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Côte d'Ivoire", code: "CIV", summers: 11, summerGold: 0, summerSilver: 1, summerBronze: 0,
    summerTotal: 1, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111,
    golds: 112, silvers: 113, bronzes: 114, total: 115 },
    { country: "Croatia", code: "HRV", summers: 5, summerGold: 3, summerSilver: 6, summerBronze: 8, summerTotal: 17,
    winters: 6, winterGold: 4, winterSilver: 5, winterBronze: 1, winterTotal: 50, games: 51, golds: 52, silvers: 53,
    bronzes: 54, total: 55 },
    { country: "Cuba", code: "CUB", summers: 18, summerGold: 67, summerSilver: 64, summerBronze: 63, summerTotal: 194,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 180, games: 181, golds: 182, silvers: 183,
    bronzes: 184, total: 185 },
    { country: "Czech Republic", code: "CZE", summers: 4, summerGold: 10, summerSilver: 12, summerBronze: 11,
    summerTotal: 33, winters: 5, winterGold: 5, winterSilver: 5, winterBronze: 6, winterTotal: 40, games: 41, golds: 42,
    silvers: 43, bronzes: 44, total: 45 },
    { country: "Czechoslovakia", code: "TCH", summers: 16, summerGold: 49, summerSilver: 49, summerBronze: 45,
    summerTotal: 143, winters: 16, winterGold: 2, winterSilver: 8, winterBronze: 15, winterTotal: 160, games: 161,
    golds: 162, silvers: 163, bronzes: 164, total: 165 },
    { country: "Denmark", code: "DNK", summers: 25, summerGold: 41, summerSilver: 63, summerBronze: 66,
    summerTotal: 170, winters: 12, winterGold: 0, winterSilver: 1, winterBronze: 0, winterTotal: 250, games: 251,
    golds: 252, silvers: 253, bronzes: 254, total: 255 },
    { country: "Djibouti", code: "DJI", summers: 7, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72, silvers: 73,
    bronzes: 74, total: 75 },
    { country: "Dominican Republic", code: "DOM", summers: 12, summerGold: 2, summerSilver: 1, summerBronze: 1,
    summerTotal: 4, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121,
    golds: 122, silvers: 123, bronzes: 124, total: 125 },
    { country: "Ecuador", code: "ECU", summers: 12, summerGold: 1, summerSilver: 1, summerBronze: 0, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Egypt", code: "EGY", summers: 20, summerGold: 7, summerSilver: 7, summerBronze: 10, summerTotal: 24,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 200, games: 201, golds: 202, silvers: 203,
    bronzes: 204, total: 205 },
    { country: "Eritrea", code: "ERI", summers: 3, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 30, games: 31, golds: 32, silvers: 33,
    bronzes: 34, total: 35 },
    { country: "Estonia", code: "EST", summers: 10, summerGold: 9, summerSilver: 8, summerBronze: 14, summerTotal: 31,
    winters: 8, winterGold: 4, winterSilver: 2, winterBronze: 1, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Ethiopia", code: "ETH", summers: 11, summerGold: 18, summerSilver: 6, summerBronze: 14, summerTotal: 38,
    winters: 2, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Finland", code: "FIN", summers: 23, summerGold: 101, summerSilver: 83, summerBronze: 115,
    summerTotal: 299, winters: 21, winterGold: 41, winterSilver: 59, winterBronze: 56, winterTotal: 230, games: 231,
    golds: 232, silvers: 233, bronzes: 234, total: 235 },
    { country: "France", code: "FRA", summers: 26, summerGold: 191, summerSilver: 212, summerBronze: 233,
    summerTotal: 636, winters: 21, winterGold: 27, winterSilver: 27, winterBronze: 40, winterTotal: 260, games: 261,
    golds: 262, silvers: 263, bronzes: 264, total: 265 },
    { country: "Georgia", code: "GEO", summers: 4, summerGold: 5, summerSilver: 2, summerBronze: 11, summerTotal: 18,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Germany", code: "DEU", summers: 22, summerGold: 247, summerSilver: 284, summerBronze: 320,
    summerTotal: 851, winters: 19, winterGold: 89, winterSilver: 93, winterBronze: 66, winterTotal: 220, games: 221,
    golds: 222, silvers: 223, bronzes: 224, total: 225 },
    { country: "East Germany", code: "GDR", summers: 5, summerGold: 153, summerSilver: 129, summerBronze: 127,
    summerTotal: 409, winters: 6, winterGold: 39, winterSilver: 36, winterBronze: 35, winterTotal: 50, games: 51,
    golds: 52, silvers: 53, bronzes: 54, total: 55 },
    { country: "Ghana", code: "GHA", summers: 12, summerGold: 0, summerSilver: 1, summerBronze: 3, summerTotal: 4,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Great Britain", code: "GBR", summers: 26, summerGold: 207, summerSilver: 255, summerBronze: 253,
    summerTotal: 715, winters: 21, winterGold: 9, winterSilver: 3, winterBronze: 10, winterTotal: 260, games: 261,
    golds: 262, silvers: 263, bronzes: 264, total: 265 },
    { country: "Greece", code: "GRC", summers: 26, summerGold: 30, summerSilver: 42, summerBronze: 36, summerTotal: 108,
    winters: 17, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 260, games: 261, golds: 262,
    silvers: 263, bronzes: 264, total: 265 },
    { country: "Guyana", code: "GUY", summers: 15, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151, golds: 152, silvers: 153,
    bronzes: 154, total: 155 },
    { country: "Haiti", code: "HTI", summers: 13, summerGold: 0, summerSilver: 1, summerBronze: 1, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Hong Kong", code: "HKG", summers: 14, summerGold: 1, summerSilver: 1, summerBronze: 0, summerTotal: 2,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Hungary", code: "HUN", summers: 24, summerGold: 159, summerSilver: 141, summerBronze: 159,
    summerTotal: 459, winters: 21, winterGold: 0, winterSilver: 2, winterBronze: 4, winterTotal: 240, games: 241,
    golds: 242, silvers: 243, bronzes: 244, total: 245 },
    { country: "Iceland", code: "ISL", summers: 18, summerGold: 0, summerSilver: 2, summerBronze: 2, summerTotal: 4,
    winters: 16, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 180, games: 181, golds: 182,
    silvers: 183, bronzes: 184, total: 185 },
    { country: "India", code: "IND", summers: 22, summerGold: 9, summerSilver: 4, summerBronze: 7, summerTotal: 20,
    winters: 8, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 220, games: 221, golds: 222, silvers: 223,
    bronzes: 224, total: 225 },
    { country: "Indonesia", code: "IDN", summers: 13, summerGold: 6, summerSilver: 9, summerBronze: 10, summerTotal: 25,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Iran", code: "IRN", summers: 14, summerGold: 11, summerSilver: 15, summerBronze: 22, summerTotal: 48,
    winters: 9, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Iraq", code: "IRQ", summers: 12, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Ireland", code: "IRL", summers: 19, summerGold: 8, summerSilver: 7, summerBronze: 8, summerTotal: 23,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 190, games: 191, golds: 192, silvers: 193,
    bronzes: 194, total: 195 },
    { country: "Israel", code: "ISR", summers: 14, summerGold: 1, summerSilver: 1, summerBronze: 5, summerTotal: 7,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Italy", code: "ITA", summers: 25, summerGold: 190, summerSilver: 157, summerBronze: 174,
    summerTotal: 521, winters: 21, winterGold: 37, winterSilver: 32, winterBronze: 37, winterTotal: 250, games: 251,
    golds: 252, silvers: 253, bronzes: 254, total: 255 },
    { country: "Jamaica", code: "JAM", summers: 15, summerGold: 13, summerSilver: 25, summerBronze: 17, summerTotal: 55,
    winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151, golds: 152, silvers: 153,
    bronzes: 154, total: 155 },
    { country: "Japan", code: "JPN", summers: 20, summerGold: 123, summerSilver: 112, summerBronze: 126,
    summerTotal: 361, winters: 19, winterGold: 9, winterSilver: 13, winterBronze: 15, winterTotal: 200, games: 201,
    golds: 202, silvers: 203, bronzes: 204, total: 205 },
    { country: "Kazakhstan", code: "KAZ", summers: 4, summerGold: 9, summerSilver: 16, summerBronze: 14,
    summerTotal: 39, winters: 5, winterGold: 1, winterSilver: 3, winterBronze: 2, winterTotal: 40, games: 41, golds: 42,
    silvers: 43, bronzes: 44, total: 45 },
    { country: "Kenya", code: "KEN", summers: 12, summerGold: 22, summerSilver: 29, summerBronze: 24, summerTotal: 75,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "North Korea", code: "PRK", summers: 8, summerGold: 10, summerSilver: 12, summerBronze: 19,
    summerTotal: 41, winters: 8, winterGold: 0, winterSilver: 1, winterBronze: 1, winterTotal: 80, games: 81, golds: 82,
    silvers: 83, bronzes: 84, total: 85 },
    { country: "South Korea", code: "KOR", summers: 15, summerGold: 68, summerSilver: 74, summerBronze: 73,
    summerTotal: 215, winters: 16, winterGold: 23, winterSilver: 14, winterBronze: 8, winterTotal: 150, games: 151,
    golds: 152, silvers: 153, bronzes: 154, total: 155 },
    { country: "Kuwait", code: "KWT", summers: 11, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Kyrgyzstan", code: "KGZ", summers: 4, summerGold: 0, summerSilver: 1, summerBronze: 2, summerTotal: 3,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Latvia", code: "LVA", summers: 9, summerGold: 2, summerSilver: 11, summerBronze: 4, summerTotal: 17,
    winters: 9, winterGold: 0, winterSilver: 2, winterBronze: 1, winterTotal: 90, games: 91, golds: 92, silvers: 93,
    bronzes: 94, total: 95 },
    { country: "Lebanon", code: "LBN", summers: 15, summerGold: 0, summerSilver: 2, summerBronze: 2, summerTotal: 4,
    winters: 15, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151, golds: 152,
    silvers: 153, bronzes: 154, total: 155 },
    { country: "Liechtenstein", code: "LIE", summers: 15, summerGold: 0, summerSilver: 0, summerBronze: 0,
    summerTotal: 0, winters: 17, winterGold: 2, winterSilver: 2, winterBronze: 5, winterTotal: 150, games: 151,
    golds: 152, silvers: 153, bronzes: 154, total: 155 },
    { country: "Lithuania", code: "LTU", summers: 7, summerGold: 4, summerSilver: 4, summerBronze: 8, summerTotal: 16,
    winters: 7, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72, silvers: 73,
    bronzes: 74, total: 75 },
    { country: "Luxembourg", code: "LUX", summers: 21, summerGold: 1, summerSilver: 1, summerBronze: 0, summerTotal: 2,
    winters: 7, winterGold: 0, winterSilver: 2, winterBronze: 0, winterTotal: 210, games: 211, golds: 212, silvers: 213,
    bronzes: 214, total: 215 },
    { country: "Macedonia", code: "MKD", summers: 4, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 4, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Malaysia", code: "MYS", summers: 13, summerGold: 0, summerSilver: 2, summerBronze: 2, summerTotal: 4,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Mauritius", code: "MUS", summers: 7, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72, silvers: 73,
    bronzes: 74, total: 75 },
    { country: "Mexico", code: "MEX", summers: 21, summerGold: 12, summerSilver: 18, summerBronze: 25, summerTotal: 55,
    winters: 7, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 210, games: 211, golds: 212, silvers: 213,
    bronzes: 214, total: 215 },
    { country: "Moldova", code: "MDA", summers: 4, summerGold: 0, summerSilver: 2, summerBronze: 3, summerTotal: 5,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Mongolia", code: "MNG", summers: 11, summerGold: 2, summerSilver: 7, summerBronze: 10, summerTotal: 19,
    winters: 12, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112,
    silvers: 113, bronzes: 114, total: 115 },
    { country: "Morocco", code: "MAR", summers: 12, summerGold: 6, summerSilver: 5, summerBronze: 10, summerTotal: 21,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Mozambique", code: "MOZ", summers: 8, summerGold: 1, summerSilver: 0, summerBronze: 1, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 80, games: 81, golds: 82, silvers: 83,
    bronzes: 84, total: 85 },
    { country: "Namibia", code: "NAM", summers: 5, summerGold: 0, summerSilver: 4, summerBronze: 0, summerTotal: 4,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 50, games: 51, golds: 52, silvers: 53,
    bronzes: 54, total: 55 },
    { country: "Netherlands", code: "NLD", summers: 23, summerGold: 71, summerSilver: 79, summerBronze: 96,
    summerTotal: 246, winters: 19, winterGold: 29, winterSilver: 31, winterBronze: 26, winterTotal: 230, games: 231,
    golds: 232, silvers: 233, bronzes: 234, total: 235 },
    { country: "Netherlands Antilles", code: "ANT", summers: 13, summerGold: 0, summerSilver: 1, summerBronze: 0,
    summerTotal: 1, winters: 2, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131,
    golds: 132, silvers: 133, bronzes: 134, total: 135 },
    { country: "New Zealand", code: "NZL", summers: 21, summerGold: 36, summerSilver: 15, summerBronze: 35,
    summerTotal: 86, winters: 14, winterGold: 0, winterSilver: 1, winterBronze: 0, winterTotal: 210, games: 211,
    golds: 212, silvers: 213, bronzes: 214, total: 215 },
    { country: "Niger", code: "NER", summers: 10, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Nigeria", code: "NGA", summers: 14, summerGold: 2, summerSilver: 9, summerBronze: 12, summerTotal: 23,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Norway", code: "NOR", summers: 23, summerGold: 54, summerSilver: 48, summerBronze: 42, summerTotal: 144,
    winters: 21, winterGold: 107, winterSilver: 106, winterBronze: 90, winterTotal: 230, games: 231, golds: 232,
    silvers: 233, bronzes: 234, total: 235 },
    { country: "Pakistan", code: "PAK", summers: 15, summerGold: 3, summerSilver: 3, summerBronze: 4, summerTotal: 10,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151, golds: 152, silvers: 153,
    bronzes: 154, total: 155 },
    { country: "Panama", code: "PAN", summers: 15, summerGold: 1, summerSilver: 0, summerBronze: 2, summerTotal: 3,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151, golds: 152, silvers: 153,
    bronzes: 154, total: 155 },
    { country: "Paraguay", code: "PRY", summers: 10, summerGold: 0, summerSilver: 1, summerBronze: 0, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Peru", code: "PER", summers: 16, summerGold: 1, summerSilver: 3, summerBronze: 0, summerTotal: 4,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 160, games: 161, golds: 162, silvers: 163,
    bronzes: 164, total: 165 },
    { country: "Philippines", code: "PHL", summers: 19, summerGold: 0, summerSilver: 2, summerBronze: 7, summerTotal: 9,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 190, games: 191, golds: 192, silvers: 193,
    bronzes: 194, total: 195 },
    { country: "Poland", code: "POL", summers: 19, summerGold: 62, summerSilver: 80, summerBronze: 119,
    summerTotal: 261, winters: 21, winterGold: 2, winterSilver: 6, winterBronze: 6, winterTotal: 190, games: 191,
    golds: 192, silvers: 193, bronzes: 194, total: 195 },
    { country: "Portugal", code: "PRT", summers: 22, summerGold: 4, summerSilver: 7, summerBronze: 11, summerTotal: 22,
    winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 220, games: 221, golds: 222, silvers: 223,
    bronzes: 224, total: 225 },
    { country: "Puerto Rico", code: "PRI", summers: 16, summerGold: 0, summerSilver: 1, summerBronze: 5, summerTotal: 6,
    winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 160, games: 161, golds: 162, silvers: 163,
    bronzes: 164, total: 165 },
    { country: "Qatar", code: "QAT", summers: 7, summerGold: 0, summerSilver: 0, summerBronze: 2, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72, silvers: 73,
    bronzes: 74, total: 75 },
    { country: "Romania", code: "ROM", summers: 19, summerGold: 86, summerSilver: 89, summerBronze: 117,
    summerTotal: 292, winters: 19, winterGold: 0, winterSilver: 0, winterBronze: 1, winterTotal: 190, games: 191,
    golds: 192, silvers: 193, bronzes: 194, total: 195 },
    { country: "Russia", code: "RUS", summers: 4, summerGold: 108, summerSilver: 97, summerBronze: 112,
    summerTotal: 317, winters: 5, winterGold: 36, winterSilver: 29, winterBronze: 26, winterTotal: 40, games: 41,
    golds: 42, silvers: 43, bronzes: 44, total: 45 },
    { country: "Russian Empire", code: "RU1", summers: 3, summerGold: 1, summerSilver: 4, summerBronze: 3,
    summerTotal: 8, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 30, games: 31, golds: 32,
    silvers: 33, bronzes: 34, total: 35 },
    { country: "Saudi Arabia", code: "SAU", summers: 9, summerGold: 0, summerSilver: 1, summerBronze: 1, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 90, games: 91, golds: 92, silvers: 93,
    bronzes: 94, total: 95 },
    { country: "Senegal", code: "SEN", summers: 12, summerGold: 0, summerSilver: 1, summerBronze: 0, summerTotal: 1,
    winters: 5, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Serbia", code: "SRB", summers: 2, summerGold: 0, summerSilver: 1, summerBronze: 2, summerTotal: 3,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 20, games: 21, golds: 22, silvers: 23,
    bronzes: 24, total: 25 },
    { country: "Serbia and Montenegro", code: "SCG", summers: 1, summerGold: 0, summerSilver: 2, summerBronze: 0,
    summerTotal: 2, winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 10, games: 11, golds: 12,
    silvers: 13, bronzes: 14, total: 15 },
    { country: "Singapore", code: "SGP", summers: 14, summerGold: 0, summerSilver: 2, summerBronze: 0, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Slovakia", code: "SVK", summers: 4, summerGold: 7, summerSilver: 8, summerBronze: 5, summerTotal: 20,
    winters: 5, winterGold: 1, winterSilver: 2, winterBronze: 1, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Slovenia", code: "SVN", summers: 5, summerGold: 3, summerSilver: 5, summerBronze: 7, summerTotal: 15,
    winters: 7, winterGold: 0, winterSilver: 2, winterBronze: 5, winterTotal: 50, games: 51, golds: 52, silvers: 53,
    bronzes: 54, total: 55 },
    { country: "South Africa", code: "ZAF", summers: 17, summerGold: 20, summerSilver: 24, summerBronze: 26,
    summerTotal: 70, winters: 6, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 170, games: 171,
    golds: 172, silvers: 173, bronzes: 174, total: 175 },
    { country: "Soviet Union", code: "URS", summers: 9, summerGold: 395, summerSilver: 319, summerBronze: 296,
    summerTotal: 1010, winters: 9, winterGold: 78, winterSilver: 57, winterBronze: 59, winterTotal: 90, games: 91,
    golds: 92, silvers: 93, bronzes: 94, total: 95 },
    { country: "Unified Team", code: "EUN", summers: 1, summerGold: 45, summerSilver: 38, summerBronze: 29,
    summerTotal: 112, winters: 1, winterGold: 9, winterSilver: 6, winterBronze: 8, winterTotal: 10, games: 11,
    golds: 12, silvers: 13, bronzes: 14, total: 15 },
    { country: "Spain", code: "ESP", summers: 20, summerGold: 34, summerSilver: 49, summerBronze: 30, summerTotal: 113,
    winters: 18, winterGold: 1, winterSilver: 0, winterBronze: 1, winterTotal: 200, games: 201, golds: 202,
    silvers: 203, bronzes: 204, total: 205 },
    { country: "Sri Lanka", code: "LKA", summers: 8, summerGold: 0, summerSilver: 2, summerBronze: 0, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 80, games: 81, golds: 82, silvers: 83,
    bronzes: 84, total: 85 },
    { country: "Sudan", code: "SDN", summers: 10, summerGold: 0, summerSilver: 1, summerBronze: 0, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Suriname", code: "SUR", summers: 11, summerGold: 1, summerSilver: 0, summerBronze: 1, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Sweden", code: "SWE", summers: 25, summerGold: 142, summerSilver: 160, summerBronze: 173,
    summerTotal: 475, winters: 21, winterGold: 48, winterSilver: 33, winterBronze: 48, winterTotal: 250, games: 251,
    golds: 252, silvers: 253, bronzes: 254, total: 255 },
    { country: "Switzerland", code: "CHE", summers: 26, summerGold: 45, summerSilver: 70, summerBronze: 66,
    summerTotal: 181, winters: 21, winterGold: 44, winterSilver: 37, winterBronze: 46, winterTotal: 260, games: 261,
    golds: 262, silvers: 263, bronzes: 264, total: 265 },
    { country: "Syria", code: "SYR", summers: 11, summerGold: 1, summerSilver: 1, summerBronze: 1, summerTotal: 3,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Tajikistan", code: "TJK", summers: 4, summerGold: 0, summerSilver: 1, summerBronze: 1, summerTotal: 2,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Tanzania", code: "TZA", summers: 11, summerGold: 0, summerSilver: 2, summerBronze: 0, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 110, games: 111, golds: 112, silvers: 113,
    bronzes: 114, total: 115 },
    { country: "Thailand", code: "THA", summers: 14, summerGold: 7, summerSilver: 4, summerBronze: 10, summerTotal: 21,
    winters: 2, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 140, games: 141, golds: 142, silvers: 143,
    bronzes: 144, total: 145 },
    { country: "Togo", code: "TGO", summers: 10, summerGold: 0, summerSilver: 0, summerBronze: 1, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Tonga", code: "TON", summers: 7, summerGold: 0, summerSilver: 1, summerBronze: 0, summerTotal: 1,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72, silvers: 73,
    bronzes: 74, total: 75 },
    { country: "Trinidad and Tobago", code: "TTO", summers: 15, summerGold: 1, summerSilver: 5, summerBronze: 8,
    summerTotal: 14, winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 150, games: 151,
    golds: 152, silvers: 153, bronzes: 154, total: 155 },
    { country: "Tunisia", code: "TUN", summers: 12, summerGold: 2, summerSilver: 2, summerBronze: 3, summerTotal: 7,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 120, games: 121, golds: 122, silvers: 123,
    bronzes: 124, total: 125 },
    { country: "Turkey", code: "TUR", summers: 20, summerGold: 37, summerSilver: 23, summerBronze: 22, summerTotal: 82,
    winters: 15, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 200, games: 201, golds: 202,
    silvers: 203, bronzes: 204, total: 205 },
    { country: "Uganda", code: "UGA", summers: 13, summerGold: 1, summerSilver: 3, summerBronze: 2, summerTotal: 6,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Ukraine", code: "UKR", summers: 4, summerGold: 28, summerSilver: 22, summerBronze: 46, summerTotal: 96,
    winters: 5, winterGold: 1, winterSilver: 1, winterBronze: 3, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "United Arab Emirates", code: "ARE", summers: 7, summerGold: 1, summerSilver: 0, summerBronze: 0,
    summerTotal: 1, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 70, games: 71, golds: 72,
    silvers: 73, bronzes: 74, total: 75 },
    { country: "United States", code: "USA", summers: 25, summerGold: 929, summerSilver: 729, summerBronze: 638,
    summerTotal: 2296, winters: 21, winterGold: 87, winterSilver: 95, winterBronze: 71, winterTotal: 250,
    games: 251, golds: 252, silvers: 253, bronzes: 254, total: 255 },
    { country: "Uruguay", code: "URY", summers: 19, summerGold: 2, summerSilver: 2, summerBronze: 6, summerTotal: 10,
    winters: 1, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 190, games: 191, golds: 192, silvers: 193,
    bronzes: 194, total: 195 },
    { country: "Uzbekistan", code: "UZB", summers: 4, summerGold: 4, summerSilver: 5, summerBronze: 8, summerTotal: 17,
    winters: 5, winterGold: 1, winterSilver: 0, winterBronze: 0, winterTotal: 40, games: 41, golds: 42, silvers: 43,
    bronzes: 44, total: 45 },
    { country: "Venezuela", code: "VEN", summers: 16, summerGold: 1, summerSilver: 2, summerBronze: 8, summerTotal: 11,
    winters: 3, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 160, games: 161, golds: 162, silvers: 163,
    bronzes: 164, total: 165 },
    { country: "Vietnam", code: "VNM", summers: 13, summerGold: 0, summerSilver: 2, summerBronze: 0, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 130, games: 131, golds: 132, silvers: 133,
    bronzes: 134, total: 135 },
    { country: "Virgin Islands", code: "VGB", summers: 10, summerGold: 0, summerSilver: 1, summerBronze: 0,
    summerTotal: 1, winters: 7, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101,
    golds: 102, silvers: 103, bronzes: 104, total: 105 },
    { country: "Yugoslavia", code: "YUG", summers: 18, summerGold: 28, summerSilver: 31, summerBronze: 31,
    summerTotal: 90, winters: 16, winterGold: 0, winterSilver: 3, winterBronze: 1, winterTotal: 180, games: 181,
    golds: 182, silvers: 183, bronzes: 184, total: 185 },
    { country: "Independent Olympic Participants", code: "IOP", summers: 1, summerGold: 0, summerSilver: 1,
    summerBronze: 2, summerTotal: 3, winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 10,
    games: 11, golds: 12, silvers: 13, bronzes: 14, total: 15 },
    { country: "Zambia", code: "ZMB", summers: 10, summerGold: 0, summerSilver: 1, summerBronze: 1, summerTotal: 2,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 100, games: 101, golds: 102, silvers: 103,
    bronzes: 104, total: 105 },
    { country: "Zimbabwe", code: "ZWE", summers: 8, summerGold: 3, summerSilver: 4, summerBronze: 1, summerTotal: 8,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 80, games: 81, golds: 82, silvers: 83,
    bronzes: 84, total: 85 },
    { country: "Mixed team", code: "ZZX", summers: 3, summerGold: 8, summerSilver: 5, summerBronze: 4, summerTotal: 17,
    winters: 0, winterGold: 0, winterSilver: 0, winterBronze: 0, winterTotal: 30, games: 31, golds: 32, silvers: 33,
    bronzes: 34, total: 35 }
  ]

  calcultePercents: ->
    o = {}
    @barPercentData.forEach (item) ->
      if !o[item.date]
        o[item.date] = 0;
      o[item.date] += item.value;

    max = 0;
    for k in o
      if(o[k] > max)
        max = o[k]

    @barPercentData.forEach (item) ->
      item.percent = item.value / o[item.date]

    @max = 0
    @lineDate.forEach (dp) =>
      @max = dp.area if dp.area > @max
