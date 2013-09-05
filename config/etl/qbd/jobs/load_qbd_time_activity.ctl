@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, source: 'qbd_time_activity'}

source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'time_activity'
}

after_read 	:flatten_hash_array, {:array_field => 'Employee'} 
after_read 	:flatten_hash_array, {:array_field => 'Vendor'} 
after_read 	:flatten_hash_array, {:array_field => 'MetaData'}

after_read	:qbd_dimensions
after_read 	:qbd_dates, {:transaction_date_field => "TxnDate"}
after_read { |row| 
  row[:amount_minutes] = row[:minutes] + 60 * row[:hours]
  row
}

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'TimesheetTransaction',
	:existing_where => @existing_where,
	:check_for_deletes => true
},
{
  :virtual => {
  	:company_id => @company_id,
  	:source => 'qbd_time_activity'
  },
  :order => {
  	:company_id => :company_id,
  	:source => :source,
  	:qbd_id => :id,
  	:status => :status,
	
  	:customer_id => :customer_id,
  	:employee_id => :employee_id,
  	:product_id => :product_id,
  	:vendor_id => :vendor_id,

  	# :job_dimension_id => :job_id,
  	# :class_dimension_id => :class_id,
	
  	:transaction_date => :txn_date,
  	:period_id => :period_id,
  	:amount_minutes => :amount_minutes
  },
	:primarykey => [:company_id, :source, :qbd_id]
}
