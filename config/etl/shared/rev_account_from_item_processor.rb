module ETL
  module Processor
    module RevAccountFromItemProcessor
      extend ActiveSupport::Concern
      included do
        attr_reader :lookup_class
         
        def process(row)
          row[:rev_account_id] = row["AccountId"]
          row[:rev_account_id] ||= row["OverrideItemAccountId"]
          if row[:rev_account_id].nil?
            @posting_type == :credit ? row[:credit_account_sk] = true : row[:debit_account_sk] = true
            product_rev_lookup = lookup_class.get_product_inc_account_lookup
            row[:rev_account_id] ||= product_rev_lookup.transform(nil, row["ItemId"], row)
            row[:rev_account_id] ||= lookup_class::get_default_rev_account
          end
      	
          row.reject!{|k,v| ["RevAccountId"].include? k }
          row
        end
      end
    end
  end
end
