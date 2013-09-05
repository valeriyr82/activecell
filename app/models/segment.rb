class Segment
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast
  include Api::LimitSizeTo50

  has_many :customers

  DEFAULT_NAME = 'General'
end
