FormErrors = require('views/shared/form_errors')

describe 'FormErrors', ->
  describe 'validationMessages', ->
    it 'should define validation error messages', ->
      messages = FormErrors.validationMessages
      expect(messages.required).toEqual("Can't be blank")
      expect(messages.url).toEqual("Is not an url address")

    describe '#validationMessageFor', ->
      describe 'for sigle error message', ->
        it 'should generate single error message', ->
          expect(FormErrors.validationMessageFor('required')).toEqual("Can't be blank")
          expect(FormErrors.validationMessageFor('url')).toEqual("Is not an url address")

      describe 'when the type is missing', ->
        it 'sohuld return the type', ->
          expect(FormErrors.validationMessageFor('undefined type')).toEqual('undefined type')

      describe 'for multiple errors', ->
        it 'should return multiple messages', ->
          expect(FormErrors.validationMessageFor('required', 'url')).toEqual("Can't be blank, Is not an url address")
          expect(FormErrors.validationMessageFor('undefined type', 'url')).toEqual("undefined type, Is not an url address")
