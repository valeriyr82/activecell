# TODO it shouldn't be here, it's not a backbone view
# TODO consider create a nice jquery plugin
$.setupLabel = ->
  if $(".checkbox input").length
    $(".checkbox").each ->
      $(@).removeClass "checked"

    $(".checkbox input:checked").each ->
      $(@).parent("label").addClass "checked"

  if $(".radio input").length
    $(".radio").each ->
      $(@).removeClass "r_on"

    $(".radio input:checked").each ->
      $(@).parent("label").addClass "r_on"

$ ->
  $(document).on "click", ".checkbox, .radio", $.setupLabel
