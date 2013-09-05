module AdvisorCompany::AdvisorDowngrade
  extend ActiveSupport::Concern

  included do
    define_callbacks :downgrade_from_advisor
    define_callbacks :upgrade_to_advisor

    set_callback :downgrade_from_advisor, :after, :destroy_affiliations!
    set_callback :upgrade_to_advisor, :before, :restore_affiliations!
  end

  def downgrade_from_advisor!
    became = becomes(Company)
    run_callbacks :downgrade_from_advisor do
      became.save!
    end

    became
  end

  private

  # Mark all advisor affiliations as deleted
  # Obsolete relations will not be visible
  def destroy_affiliations!
    advised_company_affiliations.map(&:destroy)
  end

  # Restores all deleted affiliations
  def restore_affiliations!
    advised_company_affiliations.deleted.map(&:restore)
  end
end
