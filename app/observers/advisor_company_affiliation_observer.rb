class AdvisorCompanyAffiliationObserver < Mongoid::Observer

  # Add or remove advised company add-on
  def before_update(affiliation)
    if affiliation.override_billing_changed?
      subscriber = subscriber_for(affiliation)

      company = affiliation.company
      if affiliation.override_billing?
        subscriber.add_advised_company(company)
      else
        subscriber.remove_advised_company(company)
      end
    end
  end

  # If billing is overridden remove an add-on
  # Note: advisor downgrade will trigger deleting all its affiliations
  def before_destroy(affiliation)
    if affiliation.override_billing?
      subscriber = subscriber_for(affiliation)
      company = affiliation.company

      subscriber.remove_advised_company(company)
    end
  end

  def subscriber_for(affiliation)
    affiliation.advisor_company.subscriber
  end

end
