class CompanyInvitation
  include Api::BaseDocument

  field :email, type: String
  field :token, type: String
  field :is_active, type: Boolean, default: true

  belongs_to :company, inverse_of: :invitations

  validates :email, presence: true, email: true,
                    uniqueness: { scope: :company_id, message: 'is already invited' }
  validate :user_is_not_registered

  before_create :generate_token

  index({ email: 1 })
  index({ token: 1 }, { unique: true })

  private

  def user_is_not_registered
    errors.add :email, 'is already registered' if User.where(email: email).exists?
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
