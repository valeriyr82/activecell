SubdomainGenerator = require('lib/subdomain_generator')

describe 'SubdomainGenerator', ->
  describe '#generate', ->
    it 'should downcase all characters', ->
      generator = new SubdomainGenerator('ThisIsTesTName')
      expect(generator.generate()).toEqual('thisistestname')

    it 'should substitute all white characters with dashes', ->
      generator = new SubdomainGenerator('This is TesT Name')
      expect(generator.generate()).toEqual('this-is-test-name')

    it 'should remve all illegal characters', ->
      generator = new SubdomainGenerator('With !@#$%^&*() illegal')
      expect(generator.generate()).toEqual('with-illegal')
