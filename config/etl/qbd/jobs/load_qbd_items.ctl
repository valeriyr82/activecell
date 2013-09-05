@company_id = control.options[:company_id]
@account_transform = ETL::QBD.get_account_id_lookup
@existing_where = {company_id: @company_id, qbd_id: {"$ne"=>nil}}

source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'item'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'} 

after_read { |row| 
	row[:income_account_id] 	= @account_transform.transform(
	  nil,row["IncomeAccountRef"][0]["AccountId"],row
	) unless row["IncomeAccountRef"].empty?

	row[:cogs_account_id] 	= @account_transform.transform(
	  nil,row["COGSAccountRef"][0]["AccountId"],row
	) unless row["COGSAccountRef"].empty?

	row[:expense_account_id] 	= @account_transform.transform(
	  nil,row["ExpenseAccountRef"][0]["AccountId"],row
	) unless row["ExpenseAccountRef"].empty?

	row[:asset_account_id] 	= @account_transform.transform(
	  nil,row["AssetAccountRef"][0]["AccountId"],row
	) unless row["AssetAccountRef"].empty?
	row 
}

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'Product',
	:existing_where => @existing_where,
	:check_for_deletes => true
},
{
  :virtual => {
	  :company_id => @company_id,
  },
  :order => {
  	:company_id => :company_id,
  	:qbd_id => :id,
  	:name => :name,
  	:description => :desc,
  	:income_account_id => :income_account_id,
    :cogs_account_id => :cogs_account_id,
  	:expense_account_id => :expense_account_id,
  	:asset_account_id => :asset_account_id,
  	:qbd_type => :type
  },
	:primarykey => [:company_id, :qbd_id]
}
