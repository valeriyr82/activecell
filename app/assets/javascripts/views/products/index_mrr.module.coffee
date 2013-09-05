AnalysisView = require('views/shared/analysis_view')
UpperChartView = require('views/shared/d3_chart/upper_view')

module.exports = class ProductIndexMRRView extends AnalysisView

  dashboardOptions: ->
    {
      id: 'reach'
      type: 'column'
      data: [
          {"label":"FL", "val":40000 }
          {"label":"CA", "val":30000 }
          {"label":"NY", "val":20000 }
          {"label":"NC", "val":30000 }
          {"label":"SC", "val":40000 }
          {"label":"AZ", "val":50000 }
          {"label":"TX", "val":60000 }
        ]
    } 
    
  miniChartOptions: ->
    {
      id: 'reach'
      type: 'column'
      data: [
        {"label":"FL", "val":40000 }
        {"label":"CA", "val":30000 }
        {"label":"NY", "val":20000 }
        {"label":"NC", "val":30000 }
        {"label":"SC", "val":40000 }
        {"label":"AZ", "val":50000 }
        ]
    }

  renderMain: ->
    @renderMainChart()
    # @renderHeader()
    
  renderHeader: ->
    chartSelects = [
      {nodeId: 'proportions', label: 'proportions'}
      {nodeId: 'relationships', label: 'relationships'}
    ]
    chartSelectsTemplate = JST['d3_chart/chart_selects']
    $('#main-chart-header').html chartSelectsTemplate(chartSelects: chartSelects)
    $('#group').on 'click', (event) => @mainChartView.transitionGroup()
    $('#stack').on 'click', (event) => @mainChartView.transitionStack()

  renderMainChart: ->
    @mainChartView = @createView UpperChartView, data: []
    @$('#main_chart').html @mainChartView.render().el
    @$('#main-d3-chart').css('height', '500px')
    
    @mainChartView.series.push
      id: 'donuts'
      type: 'donuts'

    themes = ["a", "b", "c", "d", "e"]
    valencies = [
      val: 0
      name: "Negative"
    ,
      val: 1
      name: "Neutral"
    ,
      val: 2
      name: "Positive"
    ]
    sexes = [
      sex: "both"
      sexName: "Both"
    ,
      sex: "male"
      sexName: "Male"
    ,
      sex: "female"
      sexName: "Female"
    ]
    ages = [
      age: "all"
      ageName: "All Ages"
    ,
      age: "young"
      ageName: "18-29"
    ,
      age: "mature"
      ageName: "30-49"
    ,
      age: "older"
      ageName: "50-65"
    ,
      age: "elderly"
      ageName: "66+"
    ]
    londoners = [
      londoner: "both"
      londonerName: "All Locations"
    ,
      londoner: "londoner"
      londonerName: "Only Londoners"
    ,
      londoner: "elsewhere"
      londonerName: "Elsewhere"
    ]
    sizes =
      small:
        inner: 0.6
        outer: 0.95
        xoffset: 0
        x_legoffset: 245
        y_legoffset: 170
      large:
        inner: 0.6
        outer: 0.85
        xoffset: 0
        x_legoffset: 645
        y_legoffset: 15
        gap_factor: 0.85

    view_modes = ["Proportions", "Relationships"]
    font_size = 15
    ring_labels = undefined
    legend_rows = undefined
    arcs = undefined
    arc = undefined
    
    # Initial Values
    settings =
      sex: "both"
      age: "all"
      londoner: "both"
      formation: "logo"
      view_mode: "Proportions"

    # Layout & Page controls
    
    # various spacing parameters
    font_size = 10
    margin = 10
    chartW = $('.main-d3-chart').width() - (2 * margin)
    chartH = $('.main-d3-chart').height() - (2 * margin)

    radius = chartW / 8
    background = "#FEFEFE"
    foreground = "#444444"
    
    # main svg for the chart
    chart = d3.select(".main-d3-chart")
      .append("div")
      .append("svg:svg")
      .attr("id", "chart_svg")
      .attr("width", chartW)
      .attr("height", chartH)
      .attr("fill", background)
    
    # Ring Setup 
    theme_map = [2, 4, 3, 1, 0]
    
    # numbers and colors
    rings = [
      ring: theme_map[0]
      color: app.formatters.colorHierarchy[0]
    ,
      ring: theme_map[1]
      color: app.formatters.colorHierarchy[1]
    ,
      ring: theme_map[2]
      color: app.formatters.colorHierarchy[2]
    ,
      ring: theme_map[3]
      color: app.formatters.colorHierarchy[3]
    ,
      ring: theme_map[4]
      color: app.formatters.colorHierarchy[4]
    ]
    
    # Set the ring positions
    rings.map (d, i) ->
      rings[i]["x"] = (theme_map[i] + 1) * radius * 1.33 + sizes.small.xoffset
      rings[i]["y"] = ((theme_map[i] % 2) * 1.9 + 1) * radius
      
    get_demographic = (s, a, l) ->
      s + "_" + a + "_" + l
    get_proportion = (tn, v, s, a, l) ->
      total = 0
      diag = undefined
      valencies.map (v) ->
        diag = tn * valencies.length + v.val
        total += dataset[get_demographic(s, a, l)][diag][diag]

      count = dataset[get_demographic(s, a, l)][tn * valencies.length + v][tn * valencies.length + v]
      count / total
    get_arc_start_position = (tn, v, s, a, l) ->
      offset = 0
      valencies.map (v2) ->
        offset += get_proportion(tn, v2.val, s, a, l)  if v2.val < v

      offset
    get_arc_end_position = (tn, v, s, a, l) ->
      get_arc_start_position(tn, v, s, a, l) + get_proportion(tn, v, s, a, l)
    
    # Animation functions

    arc_tween = (d, s, a, l) ->
      arc_start_old = get_arc_start_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner) * 2 * Math.PI
      arc_start_new = get_arc_start_position(d.theme, d.valence, s, a, l) * 2 * Math.PI
      arc_end_old = get_arc_end_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner) * 2 * Math.PI
      arc_end_new = get_arc_end_position(d.theme, d.valence, s, a, l) * 2 * Math.PI
      if settings.formation is "merged"
        arc_start_old = arc_start_old * sizes.large.gap_factor / 5 + ((d.theme - .5) * (2 / 5) * Math.PI)
        arc_end_old = arc_end_old * sizes.large.gap_factor / 5 + ((d.theme - .5) * (2 / 5) * Math.PI)
        arc_start_new = arc_start_new * sizes.large.gap_factor / 5 + ((d.theme - .5) * (2 / 5) * Math.PI)
        arc_end_new = arc_end_new * sizes.large.gap_factor / 5 + ((d.theme - .5) * (2 / 5) * Math.PI)
      iS = d3.interpolate(arc_start_old, arc_start_new)
      iE = d3.interpolate(arc_end_old, arc_end_new)
      (t) ->
        arc.startAngle(iS(t)).endAngle(iE(t))()
    get_formation_translation = (ring, formation) ->
      switch formation
        when "pentagram"
          legend_group.transition().duration(1000).attr "transform", "translate(" + sizes.large.x_legoffset + "," + sizes.large.y_legoffset + ")"
          switch ring
            when 4
              return "translate(" + ((3 * radius + sizes.large.xoffset) - (Math.cos(Math.PI / 10) * 2 * radius)) + "," + ((3 * radius) - (Math.sin(Math.PI / 10) * 2 * radius)) + ")"
            when 3
              return "translate(" + ((3 * radius + sizes.large.xoffset) - (Math.sin(Math.PI / 5) * 2 * radius)) + "," + ((3 * radius) + (Math.cos(Math.PI / 5) * 2 * radius)) + ")"
            when 0
              return "translate(" + (3 * radius + sizes.large.xoffset) + "," + radius + ")"
            when 2
              return "translate(" + ((3 * radius + sizes.large.xoffset) + (Math.sin(Math.PI / 5) * 2 * radius)) + "," + ((3 * radius) + (Math.cos(Math.PI / 5) * 2 * radius)) + ")"
            when 1
              return "translate(" + ((3 * radius + sizes.large.xoffset) + (Math.cos(Math.PI / 10) * 2 * radius)) + "," + ((3 * radius) - (Math.sin(Math.PI / 10) * 2 * radius)) + ")"
        when "merged"
          return "translate(" + (3 * radius + sizes.large.xoffset) + "," + (3 * radius) + ")"
        else #logo
          legend_group.transition().duration(1000).attr "transform", "translate(" + sizes.small.x_legoffset + "," + sizes.small.y_legoffset + ")"
          return "translate(" + rings[ring].x + "," + rings[ring].y + ")"
    
    # reposition circles
    change_formation = (new_formation) ->
      # move gs
      change_radius new_formation
      d3.selectAll(".chord_group").remove()
      ring_group.transition().duration(1000).attrTween("transform", (d) ->
        group_tween d, new_formation
      ).each "end", (e) ->
        settings.formation = new_formation

    group_tween = (ring, new_formation) ->
      i = d3.interpolate(get_formation_translation(ring, settings.formation), get_formation_translation(ring, new_formation))
      (t) ->
        i t
    
    # donut imploder/exploder
    tween_radius = (d, direction) ->
      arc_start = get_arc_start_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner)
      arc_end = get_arc_end_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner)
      implodedS = arc_start * 2 * Math.PI
      implodedE = arc_end * 2 * Math.PI
      explodedS = ((d.theme - .5) * (2 / 5) * Math.PI) + arc_start * sizes.large.gap_factor * (2 / 5) * Math.PI
      explodedE = ((d.theme - .5) * (2 / 5) * Math.PI) + arc_end * sizes.large.gap_factor * (2 / 5) * Math.PI
      implodedIR = radius * sizes.small.inner
      implodedOR = radius * sizes.small.outer
      explodedIR = 3 * radius * sizes.large.inner
      explodedOR = 3 * radius * sizes.large.outer
      if direction is "explode"
        iS = d3.interpolate(implodedS, explodedS)
        iE = d3.interpolate(implodedE, explodedE)
        iIR = d3.interpolate(implodedIR, explodedIR)
        iOR = d3.interpolate(implodedOR, explodedOR)
      else if direction is "implode"
        iS = d3.interpolate(explodedS, implodedS)
        iE = d3.interpolate(explodedE, implodedE)
        iIR = d3.interpolate(explodedIR, implodedIR)
        iOR = d3.interpolate(explodedOR, implodedOR)
      (t) ->
        arc.startAngle(iS(t)).endAngle(iE(t)).innerRadius(iIR(t)).outerRadius(iOR(t))()
    
    # explode the circles
    change_radius = (formation) ->
      if settings.formation is "merged" and formation isnt "merged"
        arcs.transition().duration(1000).attrTween "d", (d, i) ->
          tween_radius d, "implode"

      if settings.formation isnt "merged" and formation is "merged"
        arcs.transition().duration(1000).attrTween "d", (d, i) ->
          tween_radius d, "explode"

    toggle_view_mode = ->
      unless settings.formation is "merged"
        change_formation("pentagram").each "end", (e) ->
          settings.formation = "pentagram"
          ring_labels.transition().duration(1000).attr "opacity", 0
          legend_rows.transition().duration(1000).attr("opacity", 1).each "end", (e) ->
            change_formation "merged"
      else
        change_formation("pentagram").each "end", (e) ->
          settings.formation = "pentagram"
          ring_labels.transition().duration(1000).attr "opacity", 1
          legend_rows.transition().duration(1000).attr("opacity", 0).each "end", (e) ->
            change_formation "logo"

    # Chord Generation
    
    # draw chords
    draw_chords = (source_theme, source_valence) ->
      # add a group for the chords
      chord_group = chart.append("svg:g").attr("transform", "translate(" + (3 * radius + sizes.large.xoffset) + "," + (3 * radius) + ")").attr("id", "chord_group_" + source_theme + "_" + source_valence)
      # loop through the other themes
      row = (source_theme * valencies.length) + source_valence
      d = dataset[get_demographic(settings.sex, settings.age, settings.londoner)][row]
      themes.map (target_theme, target_theme_index) ->
        # find total size of the target theme
        theme_sum = 0
        valencies.map (target_valence, target_valence_index) ->
          theme_sum += d[(target_theme_index * valencies.length) + target_valence_index]

        # skip the current theme
        unless target_theme_index is source_theme
          
          # loop through the valences
          source_start = ((source_theme - .5) * (2 / 5) * Math.PI) + get_arc_start_position(source_theme, source_valence, settings.sex, settings.age, settings.londoner) * sizes.large.gap_factor * (2 / 5) * Math.PI
          source_end = ((source_theme - .5) * (2 / 5) * Math.PI) + get_arc_start_position(source_theme, source_valence, settings.sex, settings.age, settings.londoner) * sizes.large.gap_factor * (2 / 5) * Math.PI
          valencies.map (target_valence, target_valence_index) ->
            
            # update end angle
            source_end += sizes.large.gap_factor * ((d[(target_theme_index * valencies.length) + target_valence_index] / theme_sum) * (2 / 5) * Math.PI * get_proportion(source_theme, source_valence, settings.sex, settings.age, settings.londoner))
            target_start = get_arc_start_position(target_theme_index, target_valence_index, settings.sex, settings.age, settings.londoner) * sizes.large.gap_factor * 2 / 5 * Math.PI + ((target_theme_index - .5) * (2 / 5) * Math.PI)
            target_end = target_start + (d[(target_theme_index * valencies.length) + target_valence_index] / theme_sum) * get_proportion(source_theme, source_valence, settings.sex, settings.age, settings.londoner) * sizes.large.gap_factor * 2 / 5 * Math.PI
            
            # draw the chord
            chord_group.append("svg:path").attr("d", chord_generator.source(
              startAngle: source_start
              endAngle: source_end
            ).target(
              startAngle: target_start
              endAngle: target_end
            )).attr("fill-opacity", .3)
            .attr("fill", 
              app.formatters.chartColors[rings[target_theme_index].color + 60 - 10 * target_valence_index ]
            )
            .attr("stroke", background).attr("stroke-width", 2).attr("stroke-opacity", .3).attr "class", "chord_group"
            
            # update start angle
            source_start += (d[(target_theme_index * valencies.length) + target_valence_index] / theme_sum) * (2 / 5) * Math.PI * get_proportion(source_theme, source_valence, settings.sex, settings.age, settings.londoner) * sizes.large.gap_factor

    legend_group = undefined
    
    # Legend
    generate_legend = (x, y, w, h) ->
      spacing = 2

      legend_group = chart.append("svg:g").attr("transform", "translate(" + x + "," + y + ")")
      legend_group.selectAll(".legend_cell").data(d3.range(15))
        .enter()
          .append("svg:rect")
          .attr("x", (d) -> x + (w * 2 / 3) + (d % 3) * w - w / 2)
          .attr("y", (d) -> y + (Math.floor(d / 3) + 0.5) * (h + spacing) )
          .attr("height", h + "px")
          .attr("width", w + "px")
          .attr("fill", (d) ->
            app.formatters.chartColors[rings[Math.floor(d / 3)].color + (50 - 10 * (d % 3)) ]
          )
          .attr("stroke-width", 1)
          .attr("stroke", background)
          .attr "stroke-opacity", 1

      legend_rows = legend_group.selectAll(".legend_row").data(themes)
        .enter()
          .append("svg:text")
          .attr("x", x)
          .attr("y", (d, i) -> y + 3 + (i + 1) * (h + spacing))
          .text((d) -> d)
          .attr("fill", background)
          .attr("text-anchor", "end")
          .attr("font-size", font_size)
          .attr("fill", foreground)
          .attr("opacity", 0)

    # toggle buttons
    chartSelects = [
      {nodeId: 'proportions', label: 'proportions'}
      {nodeId: 'relationships', label: 'relationships'}
    ]
    chartSelectsTemplate = JST['d3_chart/chart_selects']
    $('#main-chart-header').html chartSelectsTemplate(chartSelects: chartSelects)
    $('#proportions').on 'click', (event) => 
      if $('#relationships').hasClass('active')
        $('#relationships').removeClass('active')
        $('#proportions').addClass('active')
        toggle_view_mode()
    $('#relationships').on 'click', (event) => 
      if $('#proportions').hasClass('active')
        $('#proportions').removeClass('active')
        $('#relationships').addClass('active')
        toggle_view_mode()

    chord_generator = d3.svg.chord().radius(3 * radius * sizes.large.inner)
    legend_rows = undefined
    generate_legend sizes.small.x_legoffset, sizes.small.y_legoffset, 40, 20
    
    # Load in Data
    dataset = undefined
    
    # Theoretically should be values of each theme
    ring_group = chart.selectAll(".ring_group").data(d3.range(themes.length)).enter().append("svg:g").attr("class", "ring_group").attr("opacity", 1).attr("transform", (d) ->
      get_formation_translation d, settings.formation
    )
    
      # save data
    d3.json 'assets/donut_chart_data.json', (json) ->
      dataset = json['dataset'];
      
      # make an svg:g for each ring
      # Theoretically should be values of each theme
      ring_group = chart.selectAll(".ring_group")
        .data(d3.range(themes.length))
      
      # add the title for each ring
      ring_labels = ring_group.append("svg:text")
        .text((d) -> themes[d])
        .attr("fill", foreground)
        .attr("font-size", font_size)
      
      # arc generator
      arc = d3.svg.arc()
        .innerRadius(radius * sizes.small.inner)
        .outerRadius(radius * sizes.small.outer)
        .startAngle((d) ->
          get_arc_start_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner) * 2 * Math.PI
        )
        .endAngle((d) ->
          get_arc_end_position(d.theme, d.valence, settings.sex, settings.age, settings.londoner) * 2 * Math.PI
        )
      
      # add an arc for each response
      arcs = ring_group.selectAll(".arc")
        .data((d) ->
          d3.range(valencies.length).map (i) ->
            theme: d
            valence: i
        ).enter()
        .append("svg:path")
        .attr("d", arc)
        .attr("fill", (d, i) ->
          app.formatters.chartColors[rings[d.theme].color + (50 - 10 * d.valence) ]
        )
        .attr("fill-opacity", .5)
        .attr("stroke", background)
        .attr("fill-opacity", 1)
        .attr("stroke-width", 2)
        .on("mouseover", (d) ->
          draw_chords d.theme, d.valence  if settings.formation is "merged"
        )
        .on("mouseout", (d) ->
          d3.select("#chord_group_" + d.theme + "_" + d.valence).remove()  if settings.formation is "merged"
        )
