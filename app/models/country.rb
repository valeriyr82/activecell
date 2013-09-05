class Country
  include Api::NameDocument
  field :code, type: String

  has_many :companies
end
