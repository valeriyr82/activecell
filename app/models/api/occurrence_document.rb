module Api::OccurrenceDocument
  extend ActiveSupport::Concern

  included do

    field :occurrence,       type: String
    field :occurrence_month, type: Integer

    # Returns specific JSON based on occurrence
    def as_json(options = {})
      super(only: occurrence_fields)
    end

    # TODO: add validation on create

    # Update fields based on occurence
    def update_attributes(params = {})
      super validate_attributes(params)
    end

    private

    # Cleans attributes
    def validate_attributes(params)
      params.select { |key| occurrence_fields(params['occurrence']).include?(key.to_sym) }
    end

    # Redefine this method
    def occurrence_fields
      []
    end

  end
end
