ContributorAffiliation = require('models/company/affiliation/contributor')

describe 'ContributorAffiliation', ->
  beforeEach ->
    @model = new ContributorAffiliation
      user:
        name: 'Test User'
        email: 'test.user@email.com'

  describe '#getType', ->
    it 'should return "user"', ->
      expect(@model.getType()).toEqual 'user'

  describe '#getName', ->
    it 'should return corresponing user #name', ->
      expect(@model.getName()).toEqual 'Test User'

  describe '#getEmail', ->
    it 'should return corresponing user #email', ->
      expect(@model.getEmail()).toEqual 'test.user@email.com'

  describe '#getAvatarUrl', ->
    it 'should generate url for gravatar image', ->
      spy = spyOn(app.utils, 'getGravatarFor').andReturn('http://this.is.an.url')

      expect(@model.getAvatarUrl()).toEqual 'http://this.is.an.url'
      expect(spy).toHaveBeenCalledWith 'test.user@email.com'
