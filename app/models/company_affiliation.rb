# Reflect affiliations between companies, advisor companies and users
class CompanyAffiliation
  include Api::BaseDocument

  field :has_access, type: Boolean, default: true

  attr_accessible :company_id
  attr_accessible :has_access

  default_scope order_by(_type: :asc)
  scope :with_access, where(has_access: true)

  belongs_to :company, inverse_of: :advisor_company_affiliations
  validates :company, presence: true

  def as_json(options = {})
    options.reverse_merge!(only: [:id, :has_access, :_type])
    super(options)
  end
end
