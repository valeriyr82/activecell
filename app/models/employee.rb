class Employee
  include Api::NameDocument
  include Api::BelongsCompany

  field :qbd_id,      type: String
  field :qbo_id,      type: String
  field :active,      type: String
  field :hire_date,   type: Date
  field :end_date,    type: Date

  belongs_to :employee_type

  # Returns id, name and employee_type
  # {"name"=>"Peggy Olson", "id"=>"500d3c64b0207ae648000046", "employee_type"=>{...employee type json...}}
  def as_json(options = {})
    options[:only] = [:id, :name]
    super(options).merge('employee_type' => employee_type.as_json)
  end
end
