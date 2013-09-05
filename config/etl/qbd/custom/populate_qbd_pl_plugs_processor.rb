module ETL
  module Processor
    # Public: ETL Processor to populate the data warehouse with "plug" facts
    #   to adjust for discrepancies between granular, "bottom up" data and
    #   "top down" reports known to be accurate. 
    
    #   In this case, the "top down" report is the QuickBooks Profit & Loss, 
    #   which provides sums of amounts over ranges.
    #
    # Example
    #   January value for Account A: $75,123.45 (from report n)
    #   Amounts for data warehouse transactions for Account A in February:
    #     [$60,000.00, -$4,000.00, $8,000.00, $7,000.00]
    #   Calculated "bottom up" total for Account A in February: $71,000.00
    #   Required "plug" adjustment to insert for Account A in January: 
    #     $4,123.45
    #
    class PopulateQbdPlPlugsProcessor < ETL::Processor::Processor
      attr_reader :company_id
      attr_reader :batch

      def initialize(control, configuration)
        @company_id = configuration[:company_id]
        @batch = ETL::Execution::Batch.find configuration[:batch_id]
        super
      end
      
      def process
        @company = Company.find(@company_id)
        reports = reports_from_batch
        reports.each do |report|
          # calculate scoped range
          since = report[:since].to_date
          through = report[:through].to_date
          range = since..through
          
          # eliminate any pre-existing p&l plugs in range
          @company.financial_transactions.profit_loss.plug.in_range(range).
            destroy_all

          # generate new plugs in range for matching accounts
          top_down_accounts = top_down_numbers(report) 
          bottom_up_accounts = bottom_up_numbers(range)
          top_down_accounts.each do |tda_key,tda_value|
            reconcile_accounts(tda_key, tda_value, bottom_up_accounts, through)
            bottom_up_accounts.reject!{|k,v| k == tda_key}
          end
          
          # generate plugs in range for accounts not matching
          bottom_up_accounts.each do |bua_key, bua_value|
            FinancialTransaction.create_plug!(
              :company => @company, 
              :amount_cents => (-1 * bua_value), 
              :transaction_date => through,
              :account => Account.find_by(company_id: @company_id, qbd_id: bua_key)
    	      ) unless bua_value == 0
          end
        end

    	end
    	
    	protected
    	
    	def reports_from_batch
    	  where = {:entity => :report_profit_and_loss}
    	  @batch.etl_extract_staged_responses.where(where).all
  	  end
    	
    	def top_down_numbers(report)
    	  top_down_data = {}
    	  rows = JSON.parse(report[:body])[0]["Data"][0]["DataRow"]
        rows.each do |row|
    	      qbd_account_id = row["ColData"][1]
    	      if row["ColData"][0] == "Income" || row["ColData"][0] == "Other Income"
    	        amount = (row["ColData"][5].to_f * -100).round
  	        else
  	          amount = (row["ColData"][5].to_f * 100).round
	          end
    	      top_down_data[qbd_account_id] = amount
        end
        top_down_data
    	end
    	
    	def bottom_up_numbers(range)
    	  Account.profit_loss.where(:company_id => @company_id).inject({}) do |result, element|
    	    result[element[:qbd_id]] = element.total_over(range)
    	    result
    	  end
  	  end
  	  
  	  def reconcile_accounts(qbd_account_id, amount, bottom_up_accounts, through_date)
  	    if bottom_up_accounts.has_key?(qbd_account_id)
  	      discrepancy = amount - bottom_up_accounts[qbd_account_id]
  	      FinancialTransaction.create_plug!(
            :company => @company,
            :amount_cents => discrepancy, 
            :transaction_date => through_date,
            :account => Account.find_by(company_id: @company_id, qbd_id: qbd_account_id)
  	      ) unless discrepancy == 0
	      else
	        FinancialTransaction.create_plug!(
            :company => @company,
            :amount_cents => amount, 
            :transaction_date => through_date,
            :account => Account.find_by(company_id: @company_id, qbd_id: qbd_account_id)
  	      ) unless amount == 0
        end
	    end
  	  
    end
  end
end
