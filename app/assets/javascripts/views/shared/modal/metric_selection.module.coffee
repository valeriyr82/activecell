BaseView = require('views/shared/base_view')
SearchBoxView = require('views/shared/search_box')

module.exports = class MetricSelectionView extends BaseView
  template:     JST['shared/modal/metric_selection']
  jumpToTemplate: JST['shared/modal/metric_selection/jump_to']
  listTemplate: JST['shared/modal/metric_selection/list']
  itemTemplate: JST['shared/modal/metric_selection/item']
  itemSearchTemplate: JST['shared/modal/metric_selection/item_search']
  className: 'modal hide fade metric-selection'
  events:
    'click .choose-metric'     : 'chooseMetric'
    'change .modal-select'     : 'selectChanged'
    'click .modal-link-search' : 'linkClicked'

  initialize: (options) ->
    {@callback, @skips} = options
    mediator.on('searchString:change', (ss) =>  
      @filterResults(ss)
    )

  render: (arg = {}) ->
    @allowJumpTo = arg.allowJumpTo
    @$el.html @template()
    if arg.search
      @renderSearchJump(arg.allowJumpTo)
    @renderGroups()
    searchBox = new SearchBoxView()
    @$('.search-input-box').html searchBox.render({
      placeholder : 'search all items'
    }).el
    @

  renderSearchJump: (allowJumpTo) ->
    objForTemplate = 
      allowJumpTo: allowJumpTo
    if allowJumpTo
      _.extend(objForTemplate, mass : [
          [_.extend(app.products.toJSON(), {name: 'product'}), _.extend(app.revenueStreams.toJSON(), {name: 'revenue stream'})],
          [_.extend(app.customers.toJSON(), {name: 'customer'}), _.extend(app.segments.toJSON(), {name: 'segment'}), _.extend(app.channels.toJSON(), {name: 'channel'})],
          [_.extend(app.employees.toJSON(), {name: 'employee'}), _.extend(app.employeeTypes.toJSON(), {name: 'employee type'})],
          [_.extend(app.vendors.toJSON(), {name: 'vendor'}), _.extend(app.categories.toJSON(), {name: 'category'})],
        ]
      )
    @$('.modal-search').append @jumpToTemplate(objForTemplate)

  renderGroups: ->
    analyses = app.settings.getAnalysesInGroups()
    pickGroups = (names) ->
      picked = []
      for name in names
        picked.push _.find(analyses, (analys) -> analys.name == name)
      picked
      
    categoriesGrouped = []
    categoriesGrouped.push pickGroups(['company'])
    categoriesGrouped.push pickGroups(['products', 'revenue streams'])
    categoriesGrouped.push pickGroups(['customers', 'channels', 'segments'])
    categoriesGrouped.push pickGroups(['employees', 'employee types'])
    categoriesGrouped.push pickGroups(['vendors', 'categories'])
    
    for categoriesGroup in categoriesGrouped
      @$('.modal-body').append @listTemplate(categories: categoriesGroup)
      for analysisCategory in categoriesGroup
        for analysis in analysisCategory.analyses
          if analysis.prefix is 'index'
            active = !_.include @skips, {category: analysis.analysisCategory, id: analysis.analysisId}
            @$(".modal-body ul#analysis-#{analysisCategory.id}").append @itemTemplate(
              name: analysis.name
              analysisCategory: analysis.analysisCategory
              prefix: analysis.prefix
              analysisId: analysis.analysisId
              active: active
            )

  show: ->
    @$el.modal()
    $('.modal-open').bind('keyup', (e) =>
      # escape to close modal window
      if e.keyCode is 27
        @$el.modal('hide')
        @remove()
    )

  chooseMetric: (event) ->
    event.stopPropagation()

    analysisCategory = $(event.target).attr('analysisCategory')
    analysisId = $(event.target).attr('analysisId')
    if @allowJumpTo
      document.location.hash = "##{analysisCategory}/#{analysisId}"
    else
      prefix = $(event.target).attr('prefix')
      if @model.isNew()
        @model.set(analysisCategory: analysisCategory, prefix: prefix, analysisId: analysisId)
        @model = @collection.create @model, success: () => @callback(instantRender: true)
      else
        @model.save {analysisCategory: analysisCategory, prefix: prefix, analysisId: analysisId}, success: () => @callback(instantRender: true)
        
    @$el.modal('hide')
    @remove()

  selectChanged: (e) ->
    objType = $(e.target).find(':selected').attr('id').replace(' ', '_')
    if objType is 'category'
      objType = 'categorie'
    document.location.hash = objType + 's/' + e.target.value + '/show'
    @$el.modal('hide')
    @remove()
    
  clearSearchString: () ->
    @$('.modal-search-ul-container').empty()    
    @$('.search-input-box #icon-clear').hide()
    @$('.modal-search-jump-to').show()
    @$('.modal-search-results').hide()
    @$('.search-input').val('')
    @filterBody('')

  filterResults: (searchString) ->
    @$('.modal-search-no-results').hide()
    @filterBody(searchString)
    if !searchString
      @clearSearchString()
    else
      @$('.search-input-box #icon-clear').show()
      @$('.modal-search-jump-to').hide()
      @$('.modal-search-ul-container').empty()
      @$('.modal-search-results').show()
      massNames = ['Products', 'Revenue streams', 'Customers', 'Channels', 'Segments', 'Employees', 'Employee types', 'Vendors', 'Categories']
      mass = []
      i = 0
      for collection in [app.products, app.revenueStreams, app.customers, app.channels, app.segments, app.employees, app.employeeTypes, app.vendors, app.categories]
        mass.push {
          name : massNames[i]
          collection : collection.filter((item) ->
            regExp = new RegExp(searchString, 'i')
            regExp.test(item.get('name'))
          )
        }
        i++
      for item in mass
        if item.collection.length
          @$('.modal-search-ul-container').append @listTemplate(categories: [item])
          for element in item.collection
            @$('.modal-search-ul-container ul:last').append @itemSearchTemplate(
              name: element.get('name')
              url: "#" + item.name.toLowerCase().replace(' ', '_') + '/' + element.id + '/show'
            )
      if !@$('.modal-search-ul-container').children().length
        @$('.modal-search-no-results').show()

  filterBody: (searchString) ->
    if !searchString
      @$('.modal-body li').css('opacity', '1') 
      @$('.modal-body a').css('pointer-events', 'auto')
      @$('.modal-body a').css('cursor', 'pointer')
      @$('.modal-body h4').css('opacity', '1')
    else
      @$('.modal-body li').css('opacity', '0.2')
      @$('.modal-body a').css('pointer-events', 'none')
      @$('.modal-body a').css('cursor', 'default')
      @$('.modal-body h4').css('opacity', '0.2')
      massLi = @$('.modal-list-item li').filter(() ->
        reg = new RegExp(searchString, 'i')
        reg.test($(@).text())
      )
      for element in massLi
        $(element).css('opacity' : '1')
        $(element).find('a').css('pointer-events', 'auto')
        $(element).find('a').css('cursor', 'pointer')
        $($(element).parent().prev()).css('opacity', '1')

  linkClicked: (e) ->
    @$el.modal('hide')
    @remove()
