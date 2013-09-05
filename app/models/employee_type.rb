class EmployeeType
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast
  include Api::LimitSizeTo50

  has_many :employees
  DEFAULT_NAME = 'General'
end
