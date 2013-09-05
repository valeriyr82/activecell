require 'spec_helper'

feature "Account settings page", :billing, js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:company) { create(:company, users: [user]) }

  def visit_account_setting_page
    login_as(user)
    navigate_to('settings', 'account')
  end

  context 'when company is on trial period' do
    context 'and trial is not expired' do
      before do
        company.update_attribute(:created_at, 3.days.ago)
        visit_account_setting_page
      end

      scenario 'display info about trial period' do
        within '.account-message' do
          page.should have_content("27 days left in your trial.")
        end
      end
    end

    context 'and trial is expired' do
      before do
        company.update_attribute(:created_at, 31.days.ago)
        login_as(user)
      end

      scenario 'display info about expired trial period' do
        within '#page_content' do
          page.should have_content("Trial period expired.")
        end
      end

      scenario 'hides all menus' do
        page.should_not have_css('.main-nav-wrapper')
        page.should_not have_css('#sub_nav')
      end
    end
  end

end
