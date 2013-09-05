class RevenueStream
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast
  include Api::LimitSizeTo50

  has_many :products

  DEFAULT_NAME = 'General'
end
