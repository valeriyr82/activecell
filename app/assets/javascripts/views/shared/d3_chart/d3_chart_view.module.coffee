BaseView = require('views/shared/base_view')
LegendView = require('views/shared/d3_chart/legend_view')

module.exports = class D3ChartView extends BaseView 

  initialize: (data) ->
    @data = data
    [@axes, @series, @options] = [{}, [], {}]  
    mediator.on 'route:rendered', @redrawChart
    mediator.on 'window:resize' , @redrawChart
            
  # add all template markup to the DOM
  #   the render function is called when the view is created to ensure that
  #   all markup is added to the DOM, but it waits for redrawChart() to 
  #   actually create the chart
  render: ->
    @$el.html @template
    @renderHeaderFooter()
    @

  # draws the chart, first creating the chart object if required
  #   note: this is a safer way than relying on a separate method to call 
  #   renderChart() first. this way, if the chart object needs to be created.
  #   it will be, and if it already exists, it will be updated.
  redrawChart: (duration = 750) =>
    if @svg?
      t = @svg.transition().duration(duration)
      @redrawAxes(t)
      for series in @series
        @redrawSeries(series, t)
    else
      @renderChart()

  # calls functions to create the chart object itself and then render all its
  #   components
  renderChart: ->
    @targetNode = @$(@target)
    @height = @targetNode.height() - @margin.top - @margin.bottom
    @width = @targetNode.width() - @margin.right - @margin.left
    @renderChartObject()
    @renderAxes()
    for series in @series
      @renderSeries(series)
    @renderLegend() if @legend
    @bindChartEvents()

  # creates the chart object itself
  renderChartObject: ->
    @targetNode = @$(@target)[0]
    @svg = d3.select(@targetNode).append("svg")
        .attr("width", @width + @margin.right + @margin.left)
        .attr("height", @height + @margin.top + @margin.bottom)
      .append("g")
        .attr("transform", "translate(#{@margin.left},#{@margin.top})")
    
    # Add the default clip path.
    @svg.append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", @width)
        # increase height to provide room vertically for line thickness
        .attr("height", @height + 4) 
        # translate to adjust for increased height (split the difference)
        .attr("transform", "translate(0,-2)")

    # Add the clip path.
    @svg.append("clipPath")
        .attr("id", "scatter-clip")
      .append("rect")
        # increase width to provide room vertically for circle radius
        .attr("width", @width + 12)
        # increase height to provide room vertically for circle radius
        .attr("height", @height + 12) 
        # translate to adjust for increased width and height
        .attr("transform", "translate(-6,-6)")

  # performs initial render of any axes passed from the calling class
  renderAxes: ->
    axisSettings =
      xAxis:
        range: [0, @width]
        translate: "0,#{@height + @margin.top / 4}"
      yAxis:
        range: [@height, 0]
        translate: "-#{@margin.left / 4},0"
      y2Axis:
        range: [@height, 0]
        translate: "#{@width},0"
    
    for axis, settings of axisSettings
      if @axes[axis]
        # set the range of the axis scale
        @axes[axis].scale().range(settings.range)
        # remove tick marks
        @axes[axis].tickSize(0)
        # render axis
        @svg.append("g")
          .attr("class", "axis #{axis}")
          .attr("transform", "translate(#{settings.translate})")
          .call(@axes[axis])
          
    # awful hack to remove bottom yAxis label
    @svg.selectAll(".yAxis g text").filter((d,i) ->
      (if i is 0 then true else false)
    ).style "opacity", 1e-6
    
  # updates any available axes 
  redrawAxes: (transition) ->
    for a in ['xAxis','yAxis','y2Axis']
      transition.select(".axis.#{a}")
        .call(@axes[a]) if @axes[a]

  renderSeries: (series) ->
    switch series.type
      when 'line'         then @renderLineSeries(series)
      when 'column'       then @renderColumnSeries(series)
      when 'scatter'      then @renderScatterSeries(series)
      when 'area'         then @renderAreaSeries(series)
      when 'spark line'   then @renderSparkLine(series)
      when 'leaderboard'  then @renderLeaderboard(series)
      when 'gauge'        then @renderGauge(series)
      when 'stacked area' then @renderStackedAreaSeries(series)
      when 'stacked col'  then @renderStackedColSeries(series)
        
  redrawSeries: (series, transition) ->
    switch series.type
      when 'line'         then @redrawLineSeries(series, transition)
      when 'column'       then @redrawColumnSeries(series, transition)
      when 'scatter'      then @redrawScatterSeries(series, transition)
      when 'stacked area' then @redrawStackedAreaSeries(series, transition)
      when 'stacked col'  then @redrawStackedColSeries(series, transition)
      # when 'area'         then @redrawAreaSeries(series, transition)
      # when 'spark line'   then @redrawSparkLine(series, transition)
      # when 'leaderboard'  then @redrawLeaderboard(series, transition)

  renderLineSeries: (series) ->
    line = d3.svg.line()
      .interpolate("monotone")
      .x((d) -> series.xValue(d))
      .y((d) -> series.yValue(d))
    @svg.append("svg:path")
      .attr("class", "line line-#{series.id}")
      .attr("stroke", series.color)
      .attr("clip-path", "url(#clip)")
      .attr("d", line(@data))
    @renderScatterSeries(series)

  redrawLineSeries: (series, transition) ->
    line = d3.svg.line()
      .interpolate("monotone")
      .x((d) -> series.xValue(d))
      .y((d) -> series.yValue(d))
    transition.select(".line.line-#{series.id}")
      .attr("d", line(@data))
    @redrawScatterSeries(series, transition)

  renderColumnSeries: (series) ->
    t = @svg.transition().duration(0)
    @redrawColumnSeries(series, t)

  redrawColumnSeries: (series, transition) ->
    bar = @svg.selectAll(".bar.bar-#{series.id}").data(@data)
    
    unless series.xValue?
      series.xValue = (d, i) => 
        d3.scale.linear()
        .domain([0, @data.length])
        .range([0, @width])(i)

    unless series.yValue?
      series.yValue = (d) => 
        d3.scale.linear()
        .domain([0, d3.max(@data, (d) -> d.val)])
        .range([@height, 0])(d.val) # IMPORTANT: note the flipped y values
        
    # add padding if there's a y axis    
    columnWidth = 0.92 * @width / (
      if @axes['xAxis'] then @axes['xAxis'].seriesSize else @data.length
    )
    roundedEdge = Math.round(0.05783 * columnWidth + 1)
    xPadding = if @axes['yAxis'] then columnWidth / 2 else 0
  
    bar.enter().append("svg:rect").attr("class", "bar bar-#{series.id}")
        
    if 'color' of series
      bar.attr("fill", series.color)
        
    if 'tooltip' of series
      bar.attr("data-original-title", (d) -> series.tooltip(d))
      @$(".bar.bar-#{series.id}").tooltip()

    transition.selectAll(".bar.bar-#{series.id}")
      .attr("x", (d, i) -> (series.xValue(d, i) - xPadding))
      .attr("y", (d) -> series.yValue(d))
      .attr("width", columnWidth)
      .attr("height", (d) => (@height - series.yValue(d)))
      .attr("clip-path", "url(#clip)")
      .attr("rx", roundedEdge)
      .attr("ry", roundedEdge)


    bar.exit().remove()

  renderScatterSeries: (series) ->
    t = @svg.transition().duration(0)
    @redrawScatterSeries(series, t)
      
  redrawScatterSeries: (series, transition) ->
    circle = @svg.selectAll(".point.point-#{series.id}").data(@data)
    
    circle.enter().append("svg:circle")
      .attr("class", "point point-#{series.id}")
      .attr("clip-path", "url(#scatter-clip)")
      .attr("stroke", 'white')
      .attr("r", 5)

    if 'color' of series
      circle.attr("fill", series.color)

    if 'category' of series
      circle.attr("class", (d) -> 
        "point point-#{series.id} point-#{series.category(d)}"
      )
    
    if 'tooltip' of series
      circle.attr("data-original-title", (d) -> series.tooltip(d))
      @$(".point.point-#{series.id}").tooltip
        placement: 'top'
        trigger: 'hover'
          
    transition.selectAll(".point.point-#{series.id}")
      .attr("cx", (d) -> series.xValue(d))
      .attr("cy", (d) -> series.yValue(d))
      
    circle.exit().remove()
    
  renderAreaSeries: (series) ->
    # (todo)  
    # line = d3.svg.line()
    # .interpolate("monotone")
    # .x((d) -> series.xValue(d))
    # .y((d) -> series.yValue(d))
    # 
    # @svg.append("svg:path")
    #   .attr("class", "line")
    #   .attr("stroke", series.color)
    #   .attr("clip-path", "url(#clip)")
    #   .attr("d", line(@data))

  redrawAreaSeries: (series, transition) ->
    # t.select(".area").attr("d", area(values))




  renderStackedAreaSeries: (series) ->
    stack = d3.layout.stack()
      .offset("zero")
      .values((d) -> d.values)
      .x((d) -> d.date)
      .y((d) -> d.value)

    nest = d3.nest()
      .key((d) -> d.key)

    area = d3.svg.area()
      .interpolate("cardinal")
      .x(series.xValue)
      .y0(series.y0Value)
      .y1(series.y1Value)
          
    layers = stack(nest.entries(@data))
    @axes['update']() 
    
    @svg.selectAll(".layer").data(layers)
      .enter()
        .append("path")
        .attr("class", "layer")
        .attr("d", (d) -> area(d.values))
        .style "fill", (d, i) -> 
          app.formatters.chartColors[app.formatters.colorHierarchy[i]+'30']

  redrawStackedAreaSeries: (series, transition) ->
    stack = d3.layout.stack()
      .offset("zero")
      .values((d) -> d.values)
      .x((d) -> d.date)
      .y((d) -> d.value)

    nest = d3.nest()
      .key((d) -> d.key)

    area = d3.svg.area()
      .interpolate("cardinal")
      .x(series.xValue)
      .y0(series.y0Value)
      .y1(series.y1Value)
          
    layers = stack(nest.entries(@data))
    @axes['update']()
    
    transition.selectAll(".layer").data(layers)
      .attr("d", (d) -> area d.values)    
  
  renderStackedColSeries: (series) ->
    m = 12
    n = 5
    mx = m
    my = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y0 + d.y
    )
    mz = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y
    )
    
    x = (d) => 
      d.x * @width / mx
    y0 = (d) => 
      @height - d.y0 * @height / my
    y1 = (d) => 
      @height - (d.y + d.y0) * @height / my
    y2 = (d) => 
      d.y * @height / mz # or `my` to not rescale
    
    layers = @svg.selectAll("g.layer").data(@data)
      .enter()
        .append("g")
        .attr("class", "layer")
        .style("fill", (d, i) =>
          app.formatters.chartColors[app.formatters.colorHierarchy[i]+'30']
        )
        .style("stroke", "#FFF")
    
    bars = layers.selectAll("g.bar").data((d) -> d)
      .enter()
        .append("g")
        .attr("class", "bar")
        .attr("transform", (d) -> "translate(" + x(d) + ",0)")
      
    bars.append("rect")
      .attr("width", x(x: .9))
      .attr("x", 0)
      .attr("y", @height)
      .attr("height", 0)
      .transition().delay((d, i) ->i * 10)
      .attr("y", y1)
      .attr("height", (d) -> (y0(d) - y1(d)))
    
    labels = @svg.selectAll("text.label").data(@data[0])
      .enter()
        .append("text")
        .attr("class", "label")
        .attr("x", x)
        .attr("y", @height + 6)
        .attr("dx", x(x: .45))
        .attr("dy", ".71em")
        .attr("text-anchor", "middle")
        .text((d, i) -> i)
    
    @svg.append("line")
      .attr("x1", 0)
      .attr("x2", @width - x(x: .1))
      .attr("y1", @height)
      .attr("y2", @height)
    
  redrawStackedColSeries: (series, transition) ->
    
  transitionGroup: ->
    $("#group").attr "class", "btn btn-mini active"
    $("#stack").attr "class", "btn btn-mini"

    n = 5
    m = 12

    mx = m
    my = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y0 + d.y
    )
    mz = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y
    )
    x = (d) =>
      d.x * @width / mx
    y0 = (d) =>
      @height - d.y0 * @height / my
    y1 = (d) =>
      @height - (d.y + d.y0) * @height / my
    y2 = (d) =>
      d.y * @height / mz # or `my` to not rescale

    height = @height
    transitionEnd = ->
      d3.select(@)
        .transition()
        .duration(500)
        .attr("y", (d) -> 
          height - y2(d)
        ).attr("height", y2)
        
    d3.selectAll("#main-d3-chart").selectAll("g.layer rect")
      .transition()
      .duration(500)
      .delay((d, i) -> (i % m) * 10)
      .attr("x", (d, i) -> (x(x: .9) * ~~(i / m) / n) )
      .attr("width", x(x: .9 / n))
      .each "end", transitionEnd

  transitionStack: ->
    $("#group").attr "class", "btn btn-mini"
    $("#stack").attr "class", "btn btn-mini active"

    n = 5
    m = 12

    mx = m
    my = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y0 + d.y
    )
    mz = d3.max(@data, (d) ->
      d3.max d, (d) ->
        d.y
    )
    
    x = (d) =>
      d.x * @width / mx
    y0 = (d) =>
      @height - d.y0 * @height / my
    y1 = (d) =>
      @height - (d.y + d.y0) * @height / my
    y2 = (d) =>
      d.y * @height / mz # or `my` to not rescale
      
    transitionEnd = ->
      d3.select(this)
        .transition()
        .duration(500)
        .attr("x", 0)
        .attr "width", x(x: .9)
    d3.select("#main-d3-chart").selectAll("g.layer rect")
      .transition()
      .duration(500)
      .delay((d, i) ->
        (i % m) * 10
      ).attr("y", y1).attr("height", (d) ->
        y0(d) - y1(d)
      ).each "end", transitionEnd

  renderSparkLine: (series) ->    
    x = d3.scale.linear().domain([0, @data.length]).range([0, @width])
    y = d3.scale.linear().domain([d3.min(@data), d3.max(@data)]).range([0, @height])

    line = d3.svg.line()
      .interpolate("monotone")
      .x((d, i) -> x(i)) # return index for x coordinate for now
      .y((d) -> y(d))

    @svg.append("svg:path")
      .attr("class", "sparkline")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(@data))
      
  renderLeaderboard: (series) ->
    yScale = d3.scale.linear().domain([0,1]).range([ 0, @width ])
    formatPercentage = d3.format("p")
        
    # Putting these options in an object since they may be exposed to public API
    chartoptions =
      yOffset: 45

    @svg.selectAll('bars')
        .data(@data)
        .enter()
        .append("svg:g")
        .attr("transform", "translate(-8, 50)")
        .attr("class", "leaderboard bars")

    @svg.selectAll('.leaderboard.bars')
        .append("svg:rect")
        .attr("width", '99.5%')
        .attr("height", 6)
        .attr("y", (d,i)-> i*chartoptions.yOffset)
        .attr("stroke", "black")
        .attr("rx", 4)
        .attr("ry", 4)
        .attr("class", "leaderboard track")

    @svg.selectAll('.leaderboard.bars')
        .append("svg:rect")
        .attr("height", 6)
        .attr("width", (d)-> yScale(d.value))
        .attr("y", (d,i)-> i*chartoptions.yOffset)
        .attr("rx", 4)
        .attr("class", "leaderboard bar")

    @svg.selectAll('.leaderboard.bars')
        .append("text")
        .attr("class", "leaderboard label")
        .text((d)->d.label)
        .attr("y", (d,i)-> i*chartoptions.yOffset)
        .attr("transform", "translate(3 -8)")

    @svg.selectAll('.leaderboard.bars')
        .append("text")
        .attr("class", "leaderboard value")
        .text((d)->formatPercentage(d.value))
        .attr("y", (d,i)-> i*chartoptions.yOffset)
        .attr("transform", "translate(260 -8)")

    @svg.selectAll('.leaderboard.bars')
        .append("text")
        .attr("class", "leaderboard change")
        .text((d)->formatPercentage(d.change))
        .attr("y", (d,i)-> i*chartoptions.yOffset)
        .attr("transform", "translate(272 -8)")

    @svg.selectAll('.leaderboard.bars')
        .append("svg:path")
        .attr("class", "leaderboard triangle")
        .attr("transform", (d,i)-> "translate(281,"+(i*chartoptions.yOffset-22)+")")
        .attr("d", d3.svg.symbol().size(18).type((d) ->
          if d.change > 0 then "triangle-up"
          else if d.change < 0 then "triangle-down"
        ))
        .attr("class", (d) ->
          if d.change > 0 then "triangle-up"
          else if d.change < 0 then "triangle-down"
        )

  renderGauge: (series) ->

    # load data and config
    [minValue, maxValue] = [@data[0],@data[2]]
    plotValue = @data[1]
    scale = d3.scale.linear().range([0, 1]).domain([minValue, maxValue])
    
    # this needs to scale, so no fixed pixel values!!!
    ringInset =          0.300
    ringWidth =          0.750
    pointerWidth =       0.100
    pointerTailLength =  0.015
    pointerHeadLength =  0.900
    totalSizeDivide =    1.3
    bottomOffset =       1- ( 1 - 1 / totalSizeDivide ) / 2

    minAngle = -85
    maxAngle = 85
    angleRange = maxAngle - minAngle
    
    r = Math.round( @height / totalSizeDivide )
    translateWidth = ( @width - @margin.right ) / 2
    translateHeight = @height * bottomOffset
    originTranslate = "translate(#{translateWidth}, #{translateHeight})"

    # end of config

    # outer full scale arc
    outerArc = d3.svg.arc()
      .outerRadius(r * ringWidth)
      .innerRadius(r * ringInset)
      .startAngle( @_deg2rad(minAngle) )
      .endAngle( @_deg2rad(minAngle + angleRange) )
      
    arcs = @svg.append("g")
    .attr("class", "gauge arc")
    .attr("transform", originTranslate)
    
    # main arc
    arcs.selectAll("path")
    .data([1])
    .enter()
    .append("path")
    .attr "d", outerArc
    
    

    # arc representing plot value
    plotAngle = minAngle + (scale(plotValue) * angleRange)
    innerArc = d3.svg.arc()
      .outerRadius( r * ringWidth )
      .innerRadius( r * ringInset )
      .startAngle( @_deg2rad(minAngle) )
      .endAngle( @_deg2rad(plotAngle) )
      
    arcsInner = @svg.append("g")
      .attr("class", "gauge arc-value")
      .attr("transform", originTranslate)
    
    arcsInner.selectAll("path")
      .data([1])
      .enter()
      .append("path")
      .attr "d", innerArc  
      

    # pointer
    lineData = [
      [ (r * pointerWidth / 2) , 0                        ] 
      [ 0                      , -(r * pointerHeadLength) ]
      [ -(r * pointerWidth / 2), 0                        ] 
      [ 0                      , (r * pointerTailLength)  ]
      [ (r * pointerWidth / 2) , 0                        ]
    ]

    pointerLine = d3.svg.line().interpolate("monotone")

    pg = @svg.append("g")
      .data([lineData])
      .attr("class", "gauge pointer")
      .attr("transform", originTranslate)

    pointer = pg.append("path").attr("d", pointerLine)
    pointer.transition()
      .duration(250)
      .attr("transform", "rotate(#{plotAngle})")
      
    @svg.append("svg:circle")
      .attr("r", @width / 30)
      .attr("class", "gauge pointer-circle")
      .style("opacity", 1)
      .attr "transform", originTranslate
    # pointer circle then inner-circle (nail)
    @svg.append("svg:circle")               
      .attr("r", @width / 90)
      .attr('class', 'gauge pointer-nail')
      .style("opacity", 1)
      .attr('transform', originTranslate)
            
    # labels
    if series.includeLabels?
      @svg.append("text")
          .attr("class", "gauge label")
          .text(minValue)
          .attr("transform", "translate(#{0.05 * @width}, #{@height})")
      @svg.append("text")
          .attr("class", "gauge label")
          .text(plotValue)
          .attr("transform", "translate(#{( @width - @margin.right ) / 2}, #{@height + @margin.top})")
      @svg.append("text")
          .attr("class", "gauge label")
          .text(maxValue)
          .attr("transform", "translate(#{0.95 * @width}, #{@height})")
    
  renderLegend: ->
    passedSeries = switch
      when @series? and @series[0]? and @series.type? @series[0].type is 'stacked area' 
        series = []
        _.each(_.uniq(_.pluck(@data,'key')), (key, i) -> 
          series.push {
            title: key
            color: app.formatters.chartColors[app.formatters.colorHierarchy[i]+'30']
          }
        )
        series
      when @series? and @series[0]? and 'category' of @series[0]
        series = []
        _.each(_.uniq(_.pluck(@data,'category')), (key, i) -> 
          series.push {
            title: key
            class: "point-#{key}"
          }
        )
        series
      else
        @series
    
    legendView = new LegendView(series: passedSeries)
    @$('#main-chart-legend').html legendView.render().el

  bindChartEvents: ->
    
  _deg2rad: (deg) ->
    deg * Math.PI / 180
