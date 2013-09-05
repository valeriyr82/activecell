module Company::AdvisorUpgrade
  extend ActiveSupport::Concern

  def upgrade_to_advisor!
    raise 'cannot be updated to advisor since is advised' if advised?

    became = self.becomes(AdvisorCompany)
    became.run_callbacks :upgrade_to_advisor do
      became.save!
    end

    became
  end
end
