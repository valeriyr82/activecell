require 'spec_helper'

feature 'Company settings page', js: true do
  let!(:user) { create(:user, email: 'test@user.com', name: 'First User') }
  let!(:first_user) { create(:user, email: 'other@user.com', name: 'Second User') }
  let!(:second_user) { create(:user, email: 'user@other.com') }

  let!(:advisor_company) { create(:advisor_company, name: 'Advisor company') }
  let!(:company) { create(:company, :with_country, :with_industry, users: [user, first_user]) }
  before { advisor_company.become_an_advisor_for(company) }

  background { login_as(user) }

  scenario 'list company users' do
    navigate_to('settings', 'company')
    
    within '#company-affiliations' do
      page.should have_selector('table tbody tr', :count => 3)

      # should display two users
      page.should have_content('test@user.com')
      page.should have_content('First User')

      page.should have_content('other@user.com')
      page.should have_content('Second User')

      page.should_not have_content('user@other.com')

      # should display advisor company
      page.should have_content('Advisor company')
    end
  end

  describe 'access control' do
    def change_access(affiliation, options = {})
      within "tr.company-affiliation-#{affiliation.id}" do
        find("ul.switch li.#{options[:class]}").click
        wait_until { page.has_no_content?('Saving') rescue true }
      end
    end

    def grant_an_access_for(affiliation)
      change_access(affiliation, class: 'grant-access')
    end

    def revoke_an_access_for(affiliation)
      change_access(affiliation, class: 'revoke-access')
    end

    describe 'for users' do
      let(:affiliation) { company.user_affiliations.where(user: first_user).first }

      context 'when an user has an access' do
        before do
          affiliation.update_attribute(:has_access, true)
          navigate_to('settings', 'company')
        end

        scenario 'revoke an access for the user' do
          revoke_an_access_for(affiliation)
          affiliation.reload
          affiliation.has_access.should be_false
        end
      end

      context 'when an user does not have an access' do
        before do
          affiliation.update_attribute(:has_access, false)
          navigate_to('settings', 'company')
        end

        scenario 'grant an access for the user' do
          grant_an_access_for(affiliation)
          affiliation.reload
          affiliation.has_access.should be_true
        end
      end
    end

    describe 'access control for advisor companies' do
      let(:affiliation) { company.advisor_company_affiliations.where(company: company).first }

      context 'when an advisor company has an access' do
        before do
          affiliation.update_attribute(:has_access, true)
          navigate_to('settings', 'company')
        end

        scenario 'revoke an access for the advisor' do
          revoke_an_access_for(affiliation)
          affiliation.reload
          affiliation.has_access.should be_false
        end
      end

      context 'when an advisor company does not have an access' do
        before do
          affiliation.update_attribute(:has_access, false)
          navigate_to('settings', 'company')
        end

        scenario 'grant an access for the advisor' do
          grant_an_access_for(affiliation)
          affiliation.reload
          affiliation.has_access.should be_true
        end
      end

      context 'when an advisor company overrides the billing' do
        before do
          Mongoid.observers.disable(:all) do
            affiliation.update_attribute(:override_billing, true)
          end
          navigate_to('settings', 'company')
        end

        scenario 'should not block access control switch' do
          within "tr.company-affiliation-#{affiliation.id}" do
            page.should have_content('no access')
          end
        end
      end
    end
  end

end
