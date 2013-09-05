module.exports = class SubdomainGenerator
  constructor: (@name = '') ->

  generate: ->
    @name
      .toLowerCase()                   # downcase all characters
      .replace(/[^a-zA-Z\d\-\s]/g, '') # remove illegal characters
      .replace(/(\s)+/g, '-')          # substitute white characters
