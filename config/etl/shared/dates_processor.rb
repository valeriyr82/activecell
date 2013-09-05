module ETL
  module Processor
    module DatesProcessor
      extend ActiveSupport::Concern
      included do
        attr_reader :lookup_class

        def process(row)
          @period_lookup = lookup_class.get_period_id_lookup
          row[:txn_date] = row[@transaction_date_field]
          first_day = row[:txn_date].to_date.beginning_of_month
          row[:period_id] = @period_lookup.transform('period',first_day,row)
          row.reject!{|k,v| ["PeriodId","TxnDate"].include? k }
          row 
        end
      end
    end
  end
end
