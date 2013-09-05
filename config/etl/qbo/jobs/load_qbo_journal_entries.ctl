@company_id = control.options[:company_id]
@account_transform = ETL::QBO.get_account_id_lookup
@existing_where = {company_id: @company_id, source: 'qbo_journal_entry'}

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'journal_entry'
}

after_read do |row|
  # store the id as flatten_hash_array kills it
  @qbo_id = row["Id"]
  row
end

after_read :flatten_hash_array, {:array_field => 'Header'}
after_read :flatten_hash_array, {:array_field => 'Line'}
after_read :flatten_hash_array, {:array_field => 'MetaData'}

after_read :qbo_dimensions
after_read :qbo_dates, {:transaction_date_field => "TxnDate"}

after_read do |row|
  row[:account_id] = @account_transform.transform(nil, row["AccountId"], row)
  row[:amount] = (row["Amount"].to_f * 100).round
  row[:amount] *= row["PostingType"] == "Credit" ? -1 : 1
  row[:is_credit] = row["PostingType"] == "Credit" ? 1 : 0
  row.reject! { |k, v| ["AccountId", "Amount", "IsCredit", "PostingType"].include? k }
  row
end

after_read do |row|
  if row["EntityId"].blank?
    row[:id] = @qbo_id
  else
    row[:id] = @qbo_id + "-" + row["EntityId"]
  end
  row
end

destination :out, {
    :type => :active_resource,
    :class_name => 'FinancialTransaction',
    :existing_where => @existing_where,
    :check_for_deletes => true
},
{
    :virtual => {
        :company_id => @company_id,
        :source => 'qbo_journal_entry'
    },
    :order => {
        :company_id => :company_id,
        :source => :source,
        :qbo_id => :id,
        :is_credit => :is_credit,
        :status => :status,

        :account_id => :account_id,
        :customer_id => :customer_id,
        :employee_id => :employee_id,
        :product_id => :product_id,
        :vendor_id => :vendor_id,

        :transaction_date => :txn_date,
        :period_id => :period_id,
        :amount_cents => :amount
    },
    :primarykey => [:company_id, :source, :qbo_id, :is_credit]
}
