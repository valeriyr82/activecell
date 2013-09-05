require 'spec_helper'

feature "Subdomains - an user is not signed id" do
  background { create(:company, name: 'Sterling Drooper') }

  scenario "redirect to login page since subdomain" do
    visit_and_check 'http://alfa-zapper.example.com', 'launchpad.example.com/users/sign_in'
    visit_and_check 'http://sterling-drooper.example.com/users/sign_in', 'launchpad.example.com/users/sign_in'
  end

  scenario "can use default paths" do
    visit_and_check 'http://launchpad.example.com/users/sign_up', 'launchpad.example.com/users/sign_up'
    visit_and_check 'http://launchpad.example.com/users/sign_in', 'launchpad.example.com/users/sign_in'
    visit_and_check 'http://launchpad.example.com', 'launchpad.example.com/users/sign_in'
  end

  scenario "redirect from base url to launchpad" do
    visit_and_check 'http://example.com/users/sign_up', 'launchpad.example.com/users/sign_up'
    visit_and_check 'http://example.com/users/sign_in', 'launchpad.example.com/users/sign_in'
  end
end

feature 'Subdomains - an user is signed in' do
  let!(:first_company)  { create(:company, name: 'Sterling Drooper', subdomain: 'sterling-drooper') }
  let!(:second_company) { create(:company, name: 'Donald Jammis', subdomain: 'donald-jammis') }
  let!(:user) { create(:user, companies: [first_company, second_company]) }

  background { login_as(user, login_page: root_url) }

  scenario 'can switch between local subdomains' do
    visit_and_check app_url(subdomain: first_company.subdomain), 'sterling-drooper.example.com'
    visit_and_check app_url(subdomain: second_company.subdomain), 'donald-jammis.example.com'
    visit_and_check app_url(subdomain: 'invalid'), 'sterling-drooper.example.com'

    visit_and_check 'http://example.com/users/sign_in', 'sterling-drooper.example.com'
    visit_and_check 'http://example.com', 'sterling-drooper.example.com'
    visit_and_check 'http://sterling-drooper.example.com/users/sign_out', 'launchpad.example.com/users/sign_in'
  end
end
