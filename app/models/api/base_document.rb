# Use id instead of _id. It uses in to_json method.
# Good for natural work with Backbone
#
# Examples:
#
#   new_company = Company.create(name: 'Sterling Cooper')
#   new_company.to_json
#   # => {"id": "4ff033ddb0207acd13000001", "name": "Sterling Cooper"}
module Mongoid
  module Document
    def as_json(options = {})
      attrs = super(options)
      attrs['id'] = self.persisted? ? self._id : nil
      attrs.delete('_id')
      attrs
    end
  end
end

# Alias for Mongoid::Document
# TODO: move as_json monkey-patching to this module
module Api::BaseDocument
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
  end
end
