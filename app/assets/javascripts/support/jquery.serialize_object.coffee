# Simple plugin for serializing forms to json object.
# see: https://gist.github.com/2029939
jQuery.fn.serializeObject = ->
  arrayData  = @serializeArray()
  objectData = {}

  $.each arrayData, ->
    value = @value || ''

    if objectData[@name]?
      unless objectData[@name].push
        objectData[@name] = [objectData[@name]]

      objectData[@name].push value
    else
      objectData[@name] = value

  objectData
