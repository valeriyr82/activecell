module ETL
  module Processor
    # Public: ETL Row Processor to look up revenue account from qbo_item
    #
    # This processor is used by jobs that load revenue facts, such as 
    #   qbo_invoices. The processor is essentially a hierarchy of sources
    #   for the revenue account. Once the revenue account is identified, 
    #   no further lookups are required. 
    #
    # If the account value is raw (source system id), row[:credit_account_sk]
    #   and row[:debit_account_sk] are left false. But if the value is a 
    #   surrogate key from our system, the field is set to true to bypass
    #   future lookups
    #
    class QboRevAccountFromItemProcessor < ETL::Processor::RowProcessor
      include RevAccountFromItemProcessor
      
      def initialize(control, configuration)
        @posting_type = configuration[:posting_type]
        @lookup_class = ETL::QBO
        super
      end
      
    end
  end
end
