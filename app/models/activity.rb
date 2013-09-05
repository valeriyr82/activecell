class Activity
  include Api::BaseDocument
  include Api::BelongsCompany
  include Mongoid::Timestamps

  # TODO workaround, view helpers in models are not cool, consider use decorators, or helper on js side
  include ActionView::Helpers::DateHelper

  field :content, type: String

  belongs_to :sender, class_name: 'User'
  alias_method :user, :sender

  class << self
    # Get recent messages
    def recent
      where(:created_at.gte => 3.months.ago).order_by(created_at: :desc)
    end
  end

  def as_json(options = {})
    super(options).tap do |json|
      json[:sender] = { id: sender.id, name: sender.name, email: sender.email } if sender.present?
      json[:created_at_in_words] = distance_of_time_in_words_to_now(created_at) + " ago"
    end
  end

  def users_to_notify
    ActiveCell::Queries::UsersToNotify.for(company.users, except: sender.id)
  end

end
