module User::Demo
  extend ActiveSupport::Concern

  included do
    field :demo_status,     type: String
    field :last_activity,   type: Time

    # TODO add missing specs for this scopes
    scope :demo_available, where(demo_status: 'available')
    scope :demo_taken, where(demo_status: 'taken')
    scope :demo_inactive, where(:last_activity.lte => Time.now.utc.advance(:hours => 1))
  end

  module ClassMethods
    def demo_take
      user = User.demo_available.first
      user.demo_take if user
      user
    end
  end

  # Return true if user is demo user
  def is_demo?
    !demo_status.nil?
  end

  def demo_take
    return unless is_demo?

    self.update_attribute :demo_status, 'taken'
    self.companies.each { |company| company.demo_take }
    self
  end

  def demo_active
    self.update_attribute :last_activity, Time.now.utc
  end
end
