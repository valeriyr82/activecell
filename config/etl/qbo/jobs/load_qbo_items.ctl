@company_id = control.options[:company_id]
@account_transform = ETL::QBO.get_account_id_lookup
@existing_where = {company_id: @company_id, qbo_id: {"$ne" => nil}}

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'item'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'}

after_read do |row|
  row[:income_account_id] = @account_transform.transform(
      nil, row["IncomeAccountRef"][0]["AccountId"], row
  ) unless row["IncomeAccountRef"].empty?

  row[:expense_account_id] = @account_transform.transform(
      nil, row["ExpenseAccountRef"][0]["AccountId"], row
  ) unless row["ExpenseAccountRef"].empty?

  row
end

destination :out, {
    :type => :active_resource,
    :class_name => 'Product',
    :existing_where => @existing_where,
    :check_for_deletes => true
},
{
    :virtual => {
        :company_id => @company_id,
    },
    :order => {
        :company_id => :company_id,
        :qbo_id => :id,
        :name => :name,
        :description => :desc,
        :income_account_id => :income_account_id,
        :qbo_type => :type
    },
    :primarykey => [:company_id, :qbo_id]
}
