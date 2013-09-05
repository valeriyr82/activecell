module Api::LimitSizeTo50
  extend ActiveSupport::Concern

  included do
    before_validation :limit_size

    private

    def limit_size
      if company.present?
        total_count = self.class.where(company_id: company.id).count
        if total_count == 50
          errors.add :company_id, 'Can not add more than 50 items'
        end
      end
    end
  end
end
