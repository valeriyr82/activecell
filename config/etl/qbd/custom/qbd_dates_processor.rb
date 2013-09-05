module ETL
  module Processor
    # Public: ETL Row Processor to perform foreign key lookup for period
    #   
    class QbdDatesProcessor < ETL::Processor::RowProcessor
      include ETL::Processor::DatesProcessor
      
      def initialize(control, configuration)
        @transaction_date_field = configuration[:transaction_date_field]
        @lookup_class = ETL::QBD
        super
      end
    end
  end
end
