class Task
  include Api::BaseDocument
  include Api::BelongsCompany
  include Mongoid::Timestamps

  field :done, type: Boolean, default: false
  field :done_at, type: DateTime
  field :text, type: String
  field :recurring, type: String
  field :recurrence_start, type: DateTime
  
  belongs_to :user
  validates :text, presence: true, length: { minimum: 1, maximum: 140 }
  validates_inclusion_of :recurring, in: ['monthly', 'quarterly', 'annualy'], allow_nil: true
  
  before_update :save_done_date, :save_recurrence_start
  
  def save_recurrence_start
    if recurring_changed? 
      if self.recurring
        self.recurrence_start = Time.now
      else
        self.recurrence_start = nil
      end
    end
  end
  
  def save_done_date
    self.done_at = Time.now if has_been_completed?
  end
  
  def as_json(options = {})
    super(options).tap do |json|
      json[:user] = user.as_json(only: [:email, :name])
    end
  end
  
  def self.reactivate_recurring!
    scoped.where(:recurring.exists => true).each do |task|
      task.reopen_if_needed!
    end
  end
  
  def reopen_if_needed!
    return unless done? 
    return if recurring.blank?
    return if done_at.nil?

    p_length = case recurring
      when 'monthly'
        1.month
      when 'quarterly'
        3.months
      when 'annualy'
        1.year
    end
    
    # This should never happen as it's handled by before_update filters
    # but it's not controlled on the db level so it can
    self.recurrence_start ||= self.updated_at
    
    p_start = self.recurrence_start.beginning_of_month
    p_end = p_start + p_length

    # Jump by recurring period till we found currently passing one since the recurrence start
    while !(p_start..p_end).cover?(Time.now)
      p_start = p_end
      p_end += p_length
    end

    task_is_done_for_this_period = (p_start..p_end).cover?(done_at)

    unless task_is_done_for_this_period
      self.done = false
      self.save
    end
  end

  def users_to_notify
    ActiveCell::Queries::UsersToNotify.for(company.users, except: user.id)
  end

  def has_been_completed?
    done_changed? and done?
  end

end
