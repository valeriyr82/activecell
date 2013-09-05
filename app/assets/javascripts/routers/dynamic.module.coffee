module.exports = DynamicRouter =

  typeIndex: (type)                        -> @_prepareAnalysis('typeIndex',         type, null, null)
  typeIndexAnalysis: (type, analysisId)    -> @_prepareAnalysis('typeIndexAnalysis', type, analysisId, null)
  typeShow: (type, id)                     -> @_prepareAnalysis('typeShow',          type, null,       id)
  typeShowAnalysis: (type, id, analysisId) -> @_prepareAnalysis('typeShowAnalysis',  type, analysisId, id)

  _prepareAnalysis: (way, type, analysisId, id) ->
    options = app.settings[type] ? {}

    if _.isEmpty(options)
      return app.navigate('', true)

    typeForDB = type.replace /(_\w)/g, (a) ->
      a[1].toUpperCase()

    id = app[typeForDB].get(id)?.id or null
    prefix = if id then 'show' else 'index'
    default_analysisId = options[prefix].default
    isAnalysisExists = _.include _.keys(options[prefix].analyses), analysisId

    switch way
      when 'typeIndex'         
        analysisId = default_analysisId
      when 'typeIndexAnalysis'
        unless isAnalysisExists
          return app.navigate(type, true)
      when 'typeShow'
        unless id?
          return app.navigate(type, true)
        analysisId = default_analysisId  
      when 'typeShowAnalysis'
        if not id? or not isAnalysisExists
          return app.navigate(type, true)

    viewName = "#{type}/#{prefix}_#{analysisId}"
    nav      = [options.mainNav].concat(_.compact [type, analysisId])
    @renderView viewName, nav, {id, type, analysisId, prefix}
