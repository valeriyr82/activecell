module ETL
  module Processor
    # Public: ETL Row Processor to perform foreign key lookup on 
    #   company-provided dimensions
    #
    class QboDimensionsProcessor < ETL::Processor::RowProcessor
      attr_reader :company_id
      include ETL::Processor::DimensionsProcessor
      
      def initialize(control, configuration)
        @ordering_map = configuration[:ordering_map]
        @lookup_class = ETL::QBO
        super
      end
    end
  end
end
