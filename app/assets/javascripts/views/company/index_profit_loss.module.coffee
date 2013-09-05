AnalysisView = require('views/shared/analysis_view')
UpperChartView = require('views/shared/d3_chart/upper_view')

module.exports = class CompanyProfitLossView extends AnalysisView

  renderMain: ->
    @renderMainChart()

  renderMainChart: () ->
    @mainChartView = @createView UpperChartView, data: []
    @$('#main_chart').html @mainChartView.render().el

    data = (->
      maxt = 5
      maxn = 12
      maxl = 4
      maxv = 10
      times = []
      allLinks = []
      counter = 0
      addNodes = ->
        ncount = Math.random() * maxn + 1
        nodes = d3.range(0, ncount).map((n) ->
          id: counter++
          nodeName: "Node " + n
          nodeValue: 0
          incoming: []
        )
        times.push nodes
        nodes

      addNext = ->
        current = times[times.length - 1]
        nextt = addNodes()
        # make links
        current.forEach (n) ->
          linkCount = Math.min(~~(Math.random() * maxl + 1), nextt.length)
          breaks = d3.range(linkCount - 1).map(->
            Math.random() * n.nodeValue
          ).sort(d3.ascending)
          links = {}
          target = undefined
          link = undefined
          x = undefined
          x = 0
          while x < linkCount
            loop
              target = nextt[~~(Math.random() * nextt.length)]
              break unless target.id of links
            # add link
            link =
              source: n.id
              target: target.id
              value: (breaks[x] or n.nodeValue) - (breaks[x - 1] or 0)
            links[target.id] = link
            allLinks.push link
            target.nodeValue += link.value
            x++
        # prune next
        times[times.length - 1] = nextt.filter((n) ->
          n.nodeValue
        )
      # initial set
      addNodes().forEach (n) ->
        n.nodeValue = Math.random() * maxv + 1
      # now add rest
      t = 0
      while t < maxt - 1
        addNext()
        t++
      times: times
      links: allLinks
    )()

    # Process Data 
    # make a node lookup map
    nodeMap = (->
      nm = {}
      data.times.forEach (nodes) ->
        nodes.forEach (n) ->
          nm[n.id] = n
          # add links and assure node value
          n.links = []
          n.incoming = []
          n.nodeValue = n.nodeValue or 0
      nm
    )()

    # attach links to nodes
    data.links.forEach (link) ->
      nodeMap[link.source].links.push link
      nodeMap[link.target].incoming.push link

    # sort by value and calculate offsets
    data.times.forEach (nodes) ->
      cumValue = 0
      nodes.sort (a, b) ->
        d3.descending a.nodeValue, b.nodeValue

      nodes.forEach (n, i) ->
        n.order = i
        n.offsetValue = cumValue
        cumValue += n.nodeValue

        # same for links
        lCumValue = undefined

        # outgoing
        if n.links
          lCumValue = 0
          n.links.sort (a, b) ->
            d3.descending a.value, b.value

          n.links.forEach (l) ->
            l.outOffset = lCumValue
            lCumValue += l.value

        # incoming
        if n.incoming
          lCumValue = 0
          n.incoming.sort (a, b) ->
            d3.descending a.value, b.value

          n.incoming.forEach (l) ->
            l.inOffset = lCumValue
            lCumValue += l.value

    data = data.times

    # calculate maxes
    # Make Vis 
    # settings and scales
    # root
    update = (first) ->
      # update data
      currentData = data.slice(0, ++t)
      # time slots
      times = vis.selectAll("g.time").data(currentData).enter().append("svg:g").attr("class", "time sankey-chart").attr("transform", (d, i) ->
        "translate(" + (x(i) - x(0)) + ",0)"
      )
      # node bars
      nodes = times.selectAll("g.node").data((d) ->
        d
      ).enter().append("svg:g").attr("class", "node")
      setTimeout (->
        nodes.append("svg:rect").attr("fill", "steelblue").attr("y", (n, i) ->
          y(n.offsetValue) + i * padding
        ).attr("width", x.rangeBand()).attr("height", (n) ->
          y n.nodeValue
        ).append("svg:title").text (n) ->
          n.nodeName

      ), ((if first then 0 else delay))
      linkLine = (start) ->
        (l) ->
          source = nodeMap[l.source]
          target = nodeMap[l.target]
          gapWidth = x(0)
          bandWidth = x.rangeBand() + gapWidth
          startx = x.rangeBand() - bandWidth
          sourcey = y(source.offsetValue) + source.order * padding + y(l.outOffset) + y(l.value) / 2
          targety = y(target.offsetValue) + target.order * padding + y(l.inOffset) + y(l.value) / 2
          points = (if start then [[startx, sourcey], [startx, sourcey], [startx, sourcey], [startx, sourcey]] else [[startx, sourcey], [startx + gapWidth / 2, sourcey], [startx + gapWidth / 2, targety], [0, targety]])
          line points
      # links
      links = nodes.selectAll("path.link").data((n) ->
        n.incoming or []
      ).enter().append("svg:path").attr("class", "link").style("stroke-width", (l) ->
        y l.value
      ).attr("d", linkLine(true)).on("mouseover", ->
        d3.select(this).attr "class", "link on"
      ).on("mouseout", ->
        d3.select(this).attr "class", "link"
      ).transition().duration(delay).attr("d", linkLine())
    updateNext = ->
      if t < data.length
        update()
        window.setTimeout updateNext, delay
    maxn = d3.max(data, (t) ->
      t.length
    )
    maxv = d3.max(data, (t) ->
      d3.sum t, (n) ->
        n.nodeValue
    )
    margin = 20
    w = $('#main-d3-chart').width()
    h = $('#main-d3-chart').height()
    gapratio = .7
    delay = 1500
    padding = 15
    x = d3.scale.ordinal().domain(d3.range(data.length)).rangeBands([0, w + (w / (data.length - 1))], gapratio)
    y = d3.scale.linear().domain([0, maxv]).range([0, h - padding * maxn])
    line = d3.svg.line().interpolate("basis")
    vis = d3.select("#main-d3-chart").append("svg:svg").attr("width", w).attr("height", h)
    t = 0
    update true
    updateNext()
