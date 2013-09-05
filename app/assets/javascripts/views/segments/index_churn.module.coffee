AnalysisView = require('views/shared/analysis_view')
UpperChartView = require('views/shared/d3_chart/upper_view')

module.exports = class SegmentsIndexChurnView extends AnalysisView
  
  # instantiate the analytics module and set the initial analysis timeframe
  initialize: ->
    super
    
  renderMain: ->
    # @prepareData()
    @renderMainChart()
    # @renderTable()
    
  registerKeyboardHandler = (callback) ->
    d3.select(window).on "keydown", callback

  SimpleGraph = (elemid, options) ->
    self = this
    @chart = elemid
    @cx = $(@chart).width()
    @cy = $(@chart).height()
    @options = options or {}
    @options.xmax = options.xmax or 30
    @options.xmin = options.xmin or 0
    @options.ymax = options.ymax or 10
    @options.ymin = options.ymin or 0
    @padding =
      top:    20
      right:  30
      bottom: 20
      left:   45

    @size =
      width: @cx - @padding.left - @padding.right
      height: @cy - @padding.top - @padding.bottom

    # x-scale
    @x = d3.scale.linear()
      .domain([@options.xmin, @options.xmax])
      .range([0, @size.width])

    # drag x-axis logic
    @downx = Math.NaN

    # y-scale (inverted domain)
    @y = d3.scale.linear()
      .domain([@options.ymax, @options.ymin]).nice()
      .range([0, @size.height]).nice()

    # drag y-axis logic
    @downy = Math.NaN

    @dragged = @selected = null
    @line = d3.svg.line()
      .x((d, i) -> @x @points[i].x )
      .y((d, i) -> @y @points[i].y )

    xrange = (@options.xmax - @options.xmin)
    yrange2 = (@options.ymax - @options.ymin) / 2
    yrange4 = yrange2 / 2
    datacount = @size.width / 30

    @points = d3.range(datacount).map((i) ->
      x: i * xrange / datacount
      y: @options.ymin + yrange4 + Math.random() * yrange2
    , self)

    @vis = d3.select(@chart).append("svg")
      .attr("width", @cx)
      .attr("height", @cy)
      .attr("class", "draggable-node-chart")
      .append("g")
        .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")

    @plot = @vis.append("rect")
      .attr("width", @size.width)
      .attr("height", @size.height)
      .style("fill", "#EEEEEE")
      .attr("pointer-events", "all")
      .on("mousedown.drag", self.plot_drag())
      .on("touchstart.drag", self.plot_drag())

    @plot.call d3.behavior.zoom()
      .x(@x)
      .y(@y)
      .on("zoom", @redraw())

    @vis.append("svg")
      .attr("top", 0)
      .attr("left", 0)
      .attr("width", @size.width)
      .attr("height", @size.height)
      .attr("viewBox", "0 0 " + @size.width + " " + @size.height)
      .attr("class", "line")
      .append("path")
        .attr("class", "line")
        .attr "d", @line(@points)
     
    d3.select(@chart)
      .on("mousemove.drag", self.mousemove())
      .on("touchmove.drag", self.mousemove())
      .on("mouseup.drag", self.mouseup())
      .on "touchend.drag", self.mouseup()

    @redraw()()

  #
  # SimpleGraph methods
  #
  SimpleGraph::plot_drag = ->
    self = this
    ->
      registerKeyboardHandler self.keydown()
      d3.select("body").style "cursor", "move"
      if d3.event.altKey
        p = d3.svg.mouse(self.vis.node())
        newpoint = {}
        newpoint.x = self.x.invert(Math.max(0, Math.min(self.size.width, p[0])))
        newpoint.y = self.y.invert(Math.max(0, Math.min(self.size.height, p[1])))
        self.points.push newpoint
        self.points.sort (a, b) ->
          switch
            when a.x < b.x then -1
            when a.x > b.x then 1
            else 0

        self.selected = newpoint
        self.update()
        d3.event.preventDefault()
        d3.event.stopPropagation()

  SimpleGraph::update = ->
    self = this
    lines = @vis.select("path")
      .attr("d", @line(@points))
    circle = @vis.select("svg").selectAll("circle")
      .data(@points, (d) -> d )
    
    circle.enter()
      .append("circle")
        .attr("class", (d) -> (if d is self.selected then "selected" else null))
        .attr("cx", (d) -> self.x d.x )
        .attr("cy", (d) -> self.y d.y )
        .attr("r", 10.0)
        .style("cursor", "ns-resize")
        .on("mousedown.drag", self.datapoint_drag())
        .on "touchstart.drag", self.datapoint_drag()
    
    circle
      .attr("class", (d) -> (if d is self.selected then "selected" else null))
      .attr("cx", (d) -> self.x d.x )
      .attr("cy", (d) -> self.y d.y )

    circle.exit().remove()
    
    if d3.event and d3.event.keyCode
      d3.event.preventDefault()
      d3.event.stopPropagation()

  SimpleGraph::datapoint_drag = ->
    self = this
    (d) ->
      registerKeyboardHandler self.keydown()
      document.onselectstart = ->
        false

      self.selected = self.dragged = d
      self.update()

  SimpleGraph::mousemove = ->
    self = this
    ->
      p = d3.svg.mouse(self.vis[0][0])
      t = d3.event.changedTouches
      if self.dragged
        self.dragged.y = self.y.invert(Math.max(0, Math.min(self.size.height, p[1])))
        self.update()
      unless isNaN(self.downx)
        d3.select("body").style "cursor", "ew-resize"
        rupx = self.x.invert(p[0])
        xaxis1 = self.x.domain()[0]
        xaxis2 = self.x.domain()[1]
        xextent = xaxis2 - xaxis1
        unless rupx is 0
          changex = undefined
          new_domain = undefined
          changex = self.downx / rupx
          new_domain = [xaxis1, xaxis1 + (xextent * changex)]
          self.x.domain new_domain
          self.redraw()()
        d3.event.preventDefault()
        d3.event.stopPropagation()
      unless isNaN(self.downy)
        d3.select("body").style "cursor", "ns-resize"
        rupy = self.y.invert(p[1])
        yaxis1 = self.y.domain()[1]
        yaxis2 = self.y.domain()[0]
        yextent = yaxis2 - yaxis1
        unless rupy is 0
          changey = undefined
          new_domain = undefined
          changey = self.downy / rupy
          new_domain = [yaxis1 + (yextent * changey), yaxis1]
          self.y.domain new_domain
          self.redraw()()
        d3.event.preventDefault()
        d3.event.stopPropagation()

  SimpleGraph::mouseup = ->
    self = this
    ->
      document.onselectstart = ->
        true

      d3.select("body").style "cursor", "auto"
      d3.select("body").style "cursor", "auto"
      unless isNaN(self.downx)
        self.redraw()()
        self.downx = Math.NaN
        d3.event.preventDefault()
        d3.event.stopPropagation()
      unless isNaN(self.downy)
        self.redraw()()
        self.downy = Math.NaN
        d3.event.preventDefault()
        d3.event.stopPropagation()
      self.dragged = null  if self.dragged

  SimpleGraph::keydown = ->
    self = this
    ->
      unless self.selected
        switch d3.event.keyCode
          # backspace
          when 8, 46 # delete
            i = self.points.indexOf(self.selected)
            self.points.splice i, 1
            self.selected = (if self.points.length then self.points[(if i > 0 then i - 1 else 0)] else null)
            self.update()

  SimpleGraph::redraw = ->
    self = this
    ->
      tx = (d) ->
        "translate(" + self.x(d) + ",0)"

      ty = (d) ->
        "translate(0," + self.y(d) + ")"

      stroke = (d) ->
        (if d then "#ccc" else "#666")

      fx = self.x.tickFormat(10)
      fy = self.y.tickFormat(10)

      # Regenerate x-ticks…
      gx = self.vis.selectAll("g.x").data(self.x.ticks(10), String)
        .attr("transform", tx)
      gx.select("text").text fx
      
      gxe = gx.enter().insert("g", "a")
        .attr("class", "x")
        .attr("transform", tx)
      gxe.append("line")
        .attr("stroke", stroke)
        .attr("y1", 0)
        .attr("y2", self.size.height)
      gxe.append("text")
        .attr("class", "axis")
        .attr("y", self.size.height)
        .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text(fx)
        .style("cursor", "ew-resize")
        .on("mouseover", (d) -> d3.select(this).style "font-weight", "bold")
        .on("mouseout", (d) -> d3.select(this).style "font-weight", "normal")
        .on("mousedown.drag", self.xaxis_drag())
        .on("touchstart.drag", self.xaxis_drag())
      
      gx.exit().remove()

      # Regenerate y-ticks…
      gy = self.vis.selectAll("g.y").data(self.y.ticks(10), String)
        .attr("transform", ty)
      gy.select("text").text fy
      
      gye = gy.enter().insert("g", "a")
        .attr("class", "y")
        .attr("transform", ty)
        .attr("background-fill", "#FFEEB6")
      gye.append("line")
        .attr("stroke", stroke)
        .attr("x1", 0)
        .attr("x2", self.size.width)
      gye.append("text")
        .attr("class", "axis")
        .attr("x", -3)
        .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .text(fy)
        .style("cursor", "ns-resize")
        .on("mouseover", (d) -> d3.select(this).style "font-weight", "bold")
        .on("mouseout", (d) -> d3.select(this).style "font-weight", "normal")
        .on("mousedown.drag", self.yaxis_drag())
        .on("touchstart.drag", self.yaxis_drag())
        
      gy.exit().remove()
      
      self.plot.call d3.behavior.zoom()
        .x(self.x)
        .y(self.y)
        .on("zoom", self.redraw())
      
      self.update()

  SimpleGraph::xaxis_drag = ->
    self = this
    (d) ->
      document.onselectstart = ->
        false

      p = d3.svg.mouse(self.vis[0][0])
      self.downx = self.x.invert(p[0])

  SimpleGraph::yaxis_drag = (d) ->
    self = this
    (d) ->
      document.onselectstart = ->
        false

      p = d3.svg.mouse(self.vis[0][0])
      self.downy = self.y.invert(p[1])  
    
  renderMainChart: ->
    @mainChartView = @createView UpperChartView, data: []
    @$('#main_chart').html @mainChartView.render().el
    
    graph = new SimpleGraph "#main-d3-chart", {
      xmax: 60
      xmin: 0
      ymax: 40
      ymin: 0
    }

