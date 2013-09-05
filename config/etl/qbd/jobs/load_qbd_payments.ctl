@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, source: 'qbd_payment'}

source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'payment'
}

after_read 	:flatten_hash_array, {:array_field => 'Header'} 
after_read 	:flatten_hash_array, {:array_field => 'Line'} 
after_read 	:flatten_hash_array, {:array_field => 'MetaData'}

after_read	:qbd_dimensions
after_read 	:qbd_dates, {:transaction_date_field => "TxnDate"}
after_read	:qbd_accounts, {
	:credit_account => "ARAccountId",
	:debit_account => "DepositToAccountId"
}

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'FinancialTransaction',
	:existing_where => @existing_where,
	:check_for_deletes => true
},
{
  :virtual => {
  	:company_id => @company_id,
  	:source => 'qbd_payment'
  },
  :order => {
  	:company_id => :company_id,
  	:source => :source,
  	:qbd_id => :txn_id,
  	:is_credit => :is_credit,
  	:status => :status,
	
  	:account_id => :account_id,
  	:customer_id => :customer_id,
  	:employee_id => :employee_id,
  	:product_id => :product_id,
  	:vendor_id => :vendor_id,

  	# :job_dimension_id => :job_id,
  	# :class_dimension_id => :class_id,
	
  	:transaction_date => :txn_date,
  	:period_id => :period_id,
  	:amount_cents => :amount
  },
	:primarykey => [:company_id, :source, :qbd_id, :is_credit]
}

post_process :qbd_balancing_id, {
	:company_id => @company_id, 
	:source => 'qbd_payment'
}
