@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, qbo_id: {"$ne" => nil}}
@account_type_map = JSON.parse(IO.read(Rails.root.to_s + "/config/etl/qbo/custom/qbo_account_map.json"))

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'account'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'}
# in qbo type is always nil

after_read do |row|
  row["Type"] = @account_type_map.fetch(row["Subtype"])
  row
end

destination :out, {
    :type => :active_resource,
    :class_name => 'Account',
    :existing_where => @existing_where,
    :check_for_deletes => true
},
{
    :virtual => {
        :company_id => @company_id,
    },
    :order => {
        :qbo_id => :id,
        :name => :name,
        :description => :desc,
        :type => :type,
        :sub_type => :subtype,
        :account_number => :acct_num,
        :company_id => :company_id,
        :parent_qbo_id => :account_parent_id
    },
    :primarykey => [:company_id, :qbo_id]
}

post_process {
  accounts = Account.where(@existing_where).all.to_a
  accounts.each do |parent_account|
    accounts.select { |account|
      account[:parent_qbo_id] == parent_account[:qbo_id] &&
          account[:qbo_id] != parent_account[:qbo_id]
    }.each { |child_account| child_account.update_attribute(:parent_account_id, parent_account.id) }
  end
}
