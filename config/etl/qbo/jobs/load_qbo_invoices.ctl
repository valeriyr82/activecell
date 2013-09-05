@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, source: 'qbo_invoice'}

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'invoice'
}


# save this before flatten_hash_array nils it
after_read do |row|
  row[:qbo_id] = row["Id"] + "-" + SecureRandom.uuid
  row
end

after_read :flatten_hash_array, {:array_field => 'Header'}
after_read :flatten_hash_array, {:array_field => 'Line'}
after_read :flatten_hash_array, {:array_field => 'MetaData'}

after_read :qbo_dimensions
after_read :qbo_dates, {:transaction_date_field => "TxnDate"}
after_read :qbo_rev_account_from_item, {:posting_type => :debit}
after_read { |row|
  row[:credit_account_sk] = row[:ar_account_id] = ETL::QBO.get_default_ar_account
  row
}

after_read :qbo_accounts, {
    :credit_account => :ar_account_id,
    :debit_account => :rev_account_id
}

destination :out, {
    :type => :active_resource,
    :class_name => 'FinancialTransaction',
    :existing_where => @existing_where,
    :check_for_deletes => true
},
{
    :virtual => {
        :company_id => @company_id,
        :source => 'qbo_invoice'
    },
    :order => {
        :company_id => :company_id,
        :source => :source,
        :qbo_id => :qbo_id,
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
    :primarykey => [:company_id, :source, :qbo_id, :is_credit]
}
