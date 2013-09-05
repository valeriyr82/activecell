class Period
  include Api::BaseDocument
  field :first_day, type: Date

  # Defines a system-wide default scope for transaction ranges
  default_scope where(
    :first_day.gte => Date.today.at_beginning_of_month - 36.months,
    :first_day.lte => Date.today.at_beginning_of_month + 35.months
  )

  # filter methods (in place of scopes)
  class << self
    def find_by_date(snapshot_date)
      snapshot_date = snapshot_date.to_date
      where(:first_day => snapshot_date.at_beginning_of_month).first
    end
    
    def find_id_by_date(snapshot_date)
      snapshot_date = snapshot_date.to_date
      find_by_date(snapshot_date).id
    end
    
  end
  
end