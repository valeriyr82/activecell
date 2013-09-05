@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, qbd_id: {"$ne"=>nil}}
@qbd_asset_types = [
  "Bank","Checking/Savings",
  "Accounts Receivable",
  "Other Current Asset",
	"Other Current Assets", 
	"Fixed Assets", 
	"Fixed Asset",
	"Other Asset",
	"Other Assets"
]
@account_transform = ETL::QBD.get_account_id_lookup

pre_process { 
  Account.where(@existing_where).update_all(:current_balance => 0)
}

source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'balance_sheet_std',
	:through => Time.now.to_date.to_s
}

after_read { |row| row.keys.first } # TODO Verify this row?!
after_read :flatten_hash_array, {:array_field => 'DataRow'} 
after_read { |row|
	row[:qbd_id] = row['ColData'][1].to_s
	row[:current_balance]	= (row['ColData'][5].to_f * 100).round
	row
}

# asset accounts must have the sign inverted so they balance with liability 
# and equity accounts
after_read { |row| 
	row[:current_balance] *= -1 unless 
	  @qbd_asset_types.include? row['ColData'][0].to_s
	row
}
after_read { |row| 
  row unless row[:qbd_id].nil? || row[:qbd_id] == ""
}

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'Account',
	:existing_where => @existing_where,
	:check_for_deletes => false
},
{
  :virtual => {
    :company_id => @company_id
  },
  :order => {
  	:company_id => :company_id, 
  	:qbd_id => :qbd_id,
  	:current_balance => :current_balance
  },
	:primarykey => [:company_id, :qbd_id]
}
