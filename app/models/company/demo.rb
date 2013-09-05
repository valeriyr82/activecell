module Company::Demo
  extend ActiveSupport::Concern

  included do
    field :demo_status, type: String
  end

  module ClassMethods
    def demo_available
      where(demo_status: 'available')
    end

    def demo_taken
      where(demo_status: 'taken')
    end
  end

  # Return true if company is demo company
  def is_demo?
    !demo_status.nil?
  end

  def demo_take
    return unless is_demo?

    self.update_attribute :demo_status, 'taken'
    self
  end
end
