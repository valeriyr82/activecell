require 'spec_helper'

feature 'Revenue streams page: #products/revenue_streams', js: true do
  let!(:company) { create(:company) }
  let!(:stream1) { create(:revenue_stream, company: company, name: 'Product revenue') }
  let!(:stream2) { create(:revenue_stream, company: company, name: 'Example stream') }
  let(:user) { create(:user, companies: [company], email: 'test@user.com') }

  background { login_as(user) }

  xit 'add a new revenue stream manually' do
    navigate_to('products', 'revenue streams', 'list')
    within '.main-content' do
      click_link '+ Add a stream'
  
      within 'tr.new-view' do
        fill_in 'revenue_stream[name]', with: 'New Stream'
        click_link 'Save'
      end
  
      within '.revenue-streams' do
        page.should have_content('New Stream')
      end
    end
  end

  xit 'add a new stream from suggested' do
    navigate_to('products', 'revenue streams', 'list')
    within '.main-content' do
      within '.suggested-revenue-streams' do
        page.should have_content('Customer service/support')
        page.should have_content('Product revenue')
        page.should have_content('Services revenue')

        click_link 'Services revenue'
      end

      within '.revenue-streams' do
        page.should have_content('Services revenue')
      end
    end
  end

  xit 'edit existing revenue stream' do
    navigate_to('products', 'revenue streams', 'list')

    within '.main-content' do
      within '.revenue-streams' do
        page.should have_content('Product revenue')
        page.should have_content('Example stream')

        within :xpath, '//tr[2]' do
          click_link 'Edit'
          fill_in 'revenue_stream[name]', with: 'Customer service/support'
          click_link 'Save'
        end

        within :xpath, '//tr[1]' do
          click_link 'Edit'
          click_link 'Delete'
        end

        page.should have_content('Customer service/support')
        page.should_not have_content('Product revenue')
      end
    end
  end
end
