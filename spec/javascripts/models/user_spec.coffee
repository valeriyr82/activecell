User = require('models/user')

describe 'User', ->
  beforeEach ->
    @model = new User(email: 'test@email.com')

  # TODO stub gravatar generator and write separate test for it
  describe '#getAvatarUrl', ->
    it 'should generate gravatar url', ->
      expect(@model.getAvatarUrl()).toEqual("http://www.gravatar.com/avatar/#{MD5('test@email.com')}?s=40")

    it 'should generate gravatar url for the given size', ->
      expect(@model.getAvatarUrl(size: 80)).toEqual("http://www.gravatar.com/avatar/#{MD5('test@email.com')}?s=80")
