module Api::ValidateLast
  extend ActiveSupport::Concern

  included do
    before_destroy :check_last

    private

    def check_last
      if company.present?
        total_count = self.class.where(company_id: company.id).count
        if total_count == 1
          errors.add :company_id, 'Can not delete the last remaining item'
        end
      end
    end
  end
end
