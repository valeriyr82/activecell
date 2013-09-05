module ETL
  module Processor
    # Public: ETL Processor to populate the data warehouse with "plug" facts
    #   to adjust for discrepancies between granular, "bottom up" data and
    #   "top down" reports known to be accurate. 
    
    #   In this case, the "top down" report is the QuickBooks Balance Sheet, 
    #   which provides point in time account balances. By pulling pairs of 
    #   reports, it is possible to calulate the delta representing the change
    #   in account balance over a period.
    #
    # Example
    #   January ending balance for Account A: $75,123.45 (from report n)
    #   Febrary ending balance for Account A: $95,123.45 (from report n+1)
    #   Calculated delta for Account A in Febrary: $20,000.00
    #   Amounts for data warehouse transactions for Account A in February:
    #     [$10,000.00, -$4,000.00, $8,000.00, $7,000.00]
    #   Calculated "bottom up" total for Account A in February: $21,000.00
    #   Required "plug" adjustment to insert for Account A in February: 
    #     -$1,000.00
    #   
    class PopulateQbdBalShtPlugsProcessor < ETL::Processor::Processor
      attr_reader :company_id
      attr_reader :batch

      def initialize(control, configuration)
        @company_id = configuration[:company_id]
        @batch = ETL::Execution::Batch.find configuration[:batch_id]
        @qbd_asset_types = ["Bank","Checking/Savings","Accounts Receivable",
          "Other Current Asset","Other Current Assets", "Fixed Assets", 
          "Fixed Asset","Other Asset","Other Assets"]
        super
      end
      
      def process
        @company = Company.find(@company_id)
        report_pairs = report_pairs_from_batch
        report_pairs.each do |prior, current|
          # calculate scoped range
          since = prior[:through].to_date + 1.day
          through = current[:through].to_date
          range = since..through
          
          # eliminate any pre-existing plugs in range
          @company.financial_transactions.balance_sheet.plug.in_range(range).destroy_all
            
          # generate new plugs in range for matching accounts
          top_down_accounts = top_down_numbers(prior, current) 
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
    	
    	def report_pairs_from_batch
    	  report_pairs = {} #key is prior period end of month; value is current period end of month
    	  # example: for November plugs, use the report_pairs[(10/31 bal sht)] = (11/30 bal sht)

        reports = reports_from_batch.to_a        
        reports.each do |report|
          next_report_date = [Time.now.to_date, (report[:through].to_date + 1.day).end_of_month].min
          next_report = reports.find { |rep| 
            rep[:through].to_date == next_report_date
          }
          report_pairs[report] = next_report if next_report && report != next_report
        end

        report_pairs
  	  end
    	
    	def reports_from_batch
    	  where = {:entity => :balance_sheet_std}
    	  @batch.etl_extract_staged_responses.where(where).all
  	  end
    	
    	def top_down_numbers(prior, current)

        top_down_data = {}

        prior_data = {}
        prior_rows = JSON.parse(prior[:body])["Data"][0]["DataRow"]
        prior_rows.each do |row|
          qbd_account_id = row["ColData"][1]
          if @qbd_asset_types.include? row["ColData"][0]
            amount = (row["ColData"][5].to_f * 100).round
          else
            amount = (row["ColData"][5].to_f * -100).round
          end
          prior_data[qbd_account_id] = amount unless qbd_account_id == ""
        end

        current_data = {}
        current_rows = JSON.parse(current[:body])["Data"][0]["DataRow"]
        current_rows.each do |row|
          qbd_account_id = row["ColData"][1]
          if @qbd_asset_types.include? row["ColData"][0]
            amount = (row["ColData"][5].to_f * 100).round
          else
            amount = (row["ColData"][5].to_f * -100).round
          end
          current_data[qbd_account_id] = amount unless qbd_account_id == ""
        end
        
        current_data.each do |current_key, current_value|
          if prior_data[current_key]
            delta = current_value - prior_data[current_key]
            top_down_data[current_key] = delta unless delta == 0
            prior_data.reject!{ |k,v| k == current_key }
          else
            top_down_data[current_key] = current_value unless current_value == 0
          end
        end
        
        prior_data.each do |prior_key, prior_value|
          top_down_data[prior_key] = -1 * prior_value
        end
        
        top_down_data
        
    	end
    	
    	def bottom_up_numbers(range)
    	  accounts = Account.balance_sheet.where(:company_id => @company_id)
    	  accounts.inject({}) do |result, element|
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
