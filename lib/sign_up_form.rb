class SignUpForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :params, :invitation

  attr_accessor :user
  delegate :name, :email, :password, :password_confirmation, to: :user, prefix: true

  attr_accessor :company
  delegate :name, :subdomain, to: :company, prefix: true

  def initialize(params = {})
    @params = params
    @user = User.new(user_params)
    @company = Company.new(company_params)
  end
  
  def self.from_invitation(invitation)
    return if invitation.blank?
    SignUpForm.new( {
        company_name: invitation.company.name, 
        company_subdomain: invitation.company.subdomain, 
        user_email: invitation.email
      } )
  end

  def valid?
    validate_user
    validate_company
    
    if invitation
      user.valid?
    else
      company.valid? and user.valid?
    end
  end
  
  def validate_company
    return true if invitation
    unless company.valid?
      company.errors.each do |k, v|
        errors.add(:"company_#{k}", v)
      end
    end
  end
  
  def validate_user
    unless user.valid?
      user.errors.each do |k, v|
        errors.add(:"user_#{k}", v)
      end
    end
  end

  def save
    return false unless valid?
    if invitation
      return false unless user.save
      invitation.update_attribute(:is_active, false)
      self.company = invitation.company
    else
      return false unless (user.save and company.save)
    end
    
    company.invite_user(user)
    true
  end
  
  def persisted?
    user.persisted? and company.persisted?
  end

  private

  def user_params
    params_for(:user)
  end

  def company_params
    params_for(:company)
  end

  def params_for(entity)
    key_regexp = /^#{entity}_/
    selected = params.select { |key| key.to_s.match(key_regexp) }

    Hash.new.tap do |result|
      selected.each do |key, value|
        new_key = key.to_s.gsub(key_regexp, '')
        result[new_key] = value
      end
    end
  end

end
