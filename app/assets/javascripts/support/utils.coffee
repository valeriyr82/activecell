window.l = (values...) ->
  time = new Date().toTimeString().substr(0, 8)
  console.log("[#{time}]", values...)

window.timeLog = (description, callback) ->
  start = (new Date).getTime()
  callback()
  diff = (new Date).getTime() - start
  l("#{description} \t: #{diff}ms or #{(diff/1000).toFixed 2}s") unless isTest()

window.isTest = ->
  /(\d{1,3}\.){3}/.test(location.host) or location.pathname is '/jasmine'

_.mixin
  sum: (object) ->
    _.reduce object, ((memo, val) -> memo += val), 0

  object: (prop, value) ->
    result = {}
    result[prop] = value
    result

  toCamel: (string) ->
    string.replace /(_([a-z])|-([a-z]))/g, (g) ->
      g[1].toUpperCase()

  toUnderscore: (string) ->
    string.replace /([A-Z])/g, ($1) ->
      "_" + $1.toLowerCase()

  getCaretPosition: (el) ->
    ctrl = el[0]
    caretPosition = 0;	# IE support
    if (document.selection) 
      ctrl.focus()
      sel = document.selection.createRange()
      sel.moveStart('character', - ctrl.value.length)
      caretPosition = sel.text.length

    # Firefox support
    else if (ctrl.selectionStart || ctrl.selectionStart == '0')
      caretPosition = ctrl.selectionStart

    caretPosition
