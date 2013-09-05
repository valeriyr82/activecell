module.exports =
  withCommas: (n) ->
    ("#{n}").replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,")
  usdString: (n) ->
    "$#{n}"
  percentString: (n) ->
    "#{n}%"
  collapsible: (n) ->
    if Math.abs(n) >= Math.pow(10,12)
      "#{(n/Math.pow(10,12)).toFixed(2)}T"
    else if Math.abs(n) >= Math.pow(10,9)
      "#{(n/Math.pow(10,9)).toFixed(2)}B"
    else if Math.abs(n) >= Math.pow(10,6)
      "#{(n/Math.pow(10,6)).toFixed(2)}M"
    else if Math.abs(n) >= Math.pow(10,3)
      "#{(n/Math.pow(10,3)).toFixed(2)}k"
    else 
      "#{n}"
  usdCommas: (rawCents) ->
    @usdString @withCommas Math.round(rawCents/100)
  usdCollapsible: (rawCents) ->
    @usdString @collapsible Math.round(rawCents/100)
  usdTwoPlaces: (rawCents) ->
    @usdString @twoPlacesCommas(rawCents/100)
  intCommas: (n) ->
    @withCommas Math.round(n)
  intCollapsible: (n) ->
    @collapsible Math.round(n)
  twoPlacesCommas: (n) ->
    @withCommas n.toFixed(2)
  percentIntCommas: (rawPercent) ->
    @percentString @withCommas Math.round(rawPercent*100)
  percentTwoPlacesCommas: (rawPercent) ->
    @percentString @withCommas (rawPercent*100).toFixed(2)
  percentTwoPlaces: (rawPercent) ->
    @percentString (rawPercent*100).toFixed(2)
  chartColors: {
    darkblue10: "#0B3748"
    darkblue20: "#254E5D"
    darkblue30: "#3F6672"
    darkblue40: "#597D88"
    darkblue50: "#73959D"
    darkblue60: "#8EADB3"
    blue10: "#0C1B75"
    blue20: "#263683"
    blue30: "#405192"
    blue40: "#5A6CA1"
    blue50: "#7487B0"
    blue60: "#8FA3BF"
    azure10: "#003FC1"
    azure20: "#2058C8"
    azure30: "#4072D0"
    azure40: "#608BD7"
    azure50: "#80A5DF"
    azure60: "#A0BFE7"
    lightblue10: "#4727C0"
    lightblue20: "#6043C8"
    lightblue30: "#795FD0"
    lightblue40: "#927BD8"
    lightblue50: "#AB87E0"
    lightblue60: "#C5B3E9"
    barnred10: "#4E0002"
    barnred20: "#671E20"
    barnred30: "#813D3F"
    barnred40: "#9A5C5D"
    barnred50: "#B47B7C"
    barnred60: "#CE9A9B"
    scarletred10: "#D21E17"
    scarletred20: "#D83C36"
    scarletred30: "#DE5A55"
    scarletred40: "#E47975"
    scarletred50: "#EA9794"
    scarletred60: "#F0B6B4"
    alloyorange10: "#C07200"
    alloyorange20: "#C98621"
    alloyorange30: "#D39A42"
    alloyorange40: "#DDAF63"
    alloyorange50: "#E7C384"
    alloyorange60: "#F1D8A6"
    brown10: "#623C1C"
    brown20: "#79593D"
    brown30: "#90765F"
    brown40: "#A79380"
    brown50: "#BEB0A2"
    brown60: "#D6CDC4"
    silvergrey10: "#777777"
    silvergrey20: "#8A8A8A"
    silvergrey30: "#9D9D9D"
    silvergrey40: "#B1B1B1"
    silvergrey50: "#C4C4C4"
    silvergrey60: "#D8D8D8"
    darkgrey10: "#414343"
    darkgrey20: "#4D4F4F"
    darkgrey30: "#5A5B5B"
    darkgrey40: "#676868"
    darkgrey50: "#747474"
    darkgrey60: "#818181"
  }
  colorHierarchy: [
    'blue',     'scarletred', 'lightblue',  'alloyorange',  'darkblue',
    'barnred',  'azure',      'brown',      'silvergrey',   'darkgrey'
  ]