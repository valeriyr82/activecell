@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, qbd_id: {"$ne"=>nil}}

source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'account'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'} 
after_read { |row| row["Type"] = "Non-Posting" if  row["Type"].nil?; row } 

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'Account',
	:existing_where => @existing_where,
	:check_for_deletes => true
},
{
  :virtual => {
	  :company_id => @company_id,
  },
  :order => {
    :qbd_id => :id,
    :name => :name,
    :description => :desc,
    :active => :active,
    :type => :type,
    :sub_type => :subtype,
    :account_number => :acct_num,
  	:company_id => :company_id,
  	:parent_qbd_id => :account_parent_id
  },
	:primarykey => [:company_id, :qbd_id]
}

post_process {
	accounts = Account.where(@existing_where).all.to_a
	accounts.each do |parent_account|
	  accounts.select { |account| 
	    account[:parent_qbd_id] == parent_account[:qbd_id] && 
	    account[:qbd_id] != parent_account[:qbd_id] 
	  }.each { |child_account| child_account.update_attribute(:parent_account_id, parent_account.id) }
  end
}
