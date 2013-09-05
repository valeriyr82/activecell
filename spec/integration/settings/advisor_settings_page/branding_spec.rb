require 'spec_helper'

feature 'Advisor settings page', :branding, :advisor, js: true do
  include_context 'advisor settings page'

  background do
    advisor_company.override_branding_for(second_advised_company)

    login_as(user)
    navigate_to('settings', 'advisor')
  end

  scenario 'displays checkboxes' do
    within_row_for(first_affiliation) do
      find('input[name="override_branding"]').should_not be_checked
    end

    within_row_for(second_affiliation) do
      find('input[name="override_branding"]').should be_checked
    end
  end

  scenario 'override branding' do
    within_row_for(first_affiliation) do
      check 'override_branding'
      wait_until { page.has_no_content?('Saving') rescue true }
    end

    first_affiliation.reload
    first_affiliation.override_branding.should be_true
  end

  scenario 'rollback override branding' do
    within_row_for(second_affiliation) do
      uncheck 'override_branding'
      wait_until { page.has_no_content?('Saving') rescue true }
    end

    second_affiliation.reload
    second_affiliation.override_branding.should be_false
  end

  context 'when the branding is overridden by other advisor' do
    let!(:other_advisor_company) { create(:advisor_company) }
    let!(:third_advised_company) { create(:company) }

    before do
      advisor_company.become_an_advisor_for(third_advised_company)
      other_advisor_company.become_an_advisor_for(third_advised_company)
      other_advisor_company.override_branding_for(third_advised_company)

      navigate_to('settings', 'advisor')
    end

    let(:third_affiliation) { advisor_company_affiliation_for(third_advised_company) }

    scenario 'should display notification about overridden banding' do
      within_row_for(third_affiliation) do
        page.should have_content("This company's branding is already overridden by another advisor.")
      end
    end
  end
end
