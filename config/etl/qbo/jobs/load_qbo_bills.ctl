@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, source: 'qbo_bill'}

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'bill'
}

after_read { |row| @qbo_id = row["Id"]; row }
after_read :flatten_hash_array, {:array_field => 'Header'}
after_read :flatten_hash_array, {:array_field => 'Line'}
after_read :flatten_hash_array, {:array_field => 'MetaData'}

after_read :qbo_dimensions
after_read :qbo_dates, {:transaction_date_field => "TxnDate"}
after_read { |row|
  row[:credit_account_sk] = row[:ap_account_id] = ETL::QBO.get_default_ap_account
  row
}

after_read :qbo_exp_account_from_item, {:posting_type => :debit}
after_read :qbo_accounts, {
    :credit_account => :ap_account_id,
    :debit_account => :exp_account_id
}

after_read do |row|
  row[:id] = @qbo_id.strip + "-" + row["Id"]
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
        :source => 'qbo_bill'
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
