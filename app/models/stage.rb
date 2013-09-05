class Stage
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast
  include Api::LimitSizeTo50

  field :position,    type: Integer,  default: 1
  field :lag_periods, type: Integer,  default: 0

  validates :position,  presence: true,
                        uniqueness: {scope: :company_id}

  DEFAULT_NAME = 'Customer'

  def <=>(other)
    position <=> other.position
  end

end
