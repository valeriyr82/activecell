class User
  include Api::BaseDocument
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include User::Demo
  include User::UserVoice
  include User::IntuitSso
  include User::Affiliations

  devise :database_authenticatable, :recoverable, :registerable, :validatable, :rememberable

  field :name, type: String

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''
  
  ## Rememberable
  field :remember_created_at, type: Time
  
  field :email_notifications, type: Boolean, default: true

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  index({ email: 1 })

  has_many :tasks

  validates :name, presence: true

  class << self
    # Finds user by email. Method is not case sensitive
    def find_by_email(email)
      where(email: /^#{email}$/i).first
    end
  end

  def as_json(options = {})
    options.reverse_merge!(only: [:id, :name, :email, :email_notifications, :created_at, :updated_at, :company_ids])
    super(options).merge('companies' => companies.as_json(only: [:id, :name, :subdomain]))
  end

end
