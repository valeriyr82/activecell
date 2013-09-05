# Reflects affiliation between company and users
class UserAffiliation < CompanyAffiliation

  belongs_to :user, inverse_of: :company_affiliations
  validates :user, presence: true,
            uniqueness: { scope: :company_id }

  attr_accessible :user_id

  index({ company: 1, user: 1 }, { unique: true })

  def as_json(options = {})
    super(options).tap do |json|
      json[:user] = user.as_json(only: [:id, :email, :name])
    end
  end
end
