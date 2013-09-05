class Document
  include Api::BaseDocument
  include Api::BelongsCompany

  field :response, type: String
  field :document_type, type: String

  validates_presence_of :response
end
