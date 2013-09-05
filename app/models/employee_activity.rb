class EmployeeActivity
  include Api::NameDocument
  
  NAMED_ACTIVITIES = {
    sales: 'Sales',
    marketing: 'Marketing',
    billable: 'Billable time',
    general: 'General/admin'
  }
  
end