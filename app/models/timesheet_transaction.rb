class TimesheetTransaction
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::SummaryDocument

  field :amount_minutes,  type: Integer
  field :source,          type: String
  field :qbd_id,          type: String
  field :qbo_id,          type: String
  field :status,          type: String

  has_summaries sum_field: :amount_minutes,
                group_by_fields: [:period_id, :employee_activity_id, :employee_id, :product_id, :customer_id]
                
  belongs_to :period              
  belongs_to :customer
  belongs_to :employee
  belongs_to :product
  belongs_to :vendor
  belongs_to :employee_activity

  validates :amount_minutes, presence: true
end
