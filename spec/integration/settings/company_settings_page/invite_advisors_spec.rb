# require 'spec_helper'
# 
# feature 'Company settings page', :advisor, js: true do
#   let!(:user) { create(:user, email: 'test@user.com', name: 'First User') }
# 
#   let!(:advisor_user) { create(:user, email: 'advisor@user.com') }
#   let!(:second_advisor_user) { create(:user, email: 'second.advisor@user.com') }
# 
#   let!(:advisor_company) { create(:advisor_company, name: 'Advisor Company',
#                                   users: [advisor_user]) }
#   let!(:second_advisor_company) { create(:advisor_company, name: 'Second Advisor Company',
#                                   users: [advisor_user, second_advisor_user]) }
# 
#   def visit_company_settings_page
#     login_as(user)
#     navigate_to('settings', 'company')
#   end
# 
#   def invite_advisor_by(email)
#     within 'form.form-add-user' do
#       fill_in 'email', with: email
#       click_button 'Invite'
#     end
# 
#     wait_until { page.has_css?('.advisor-invitation-dialog') }
#   end
# 
#   context 'when the company is not an advisor' do
#     let!(:company) { create(:company, users: [user]) }
#     before { visit_company_settings_page }
# 
#     context 'when the given advisor user has only one advisor company' do
#       scenario 'add an advisor as regular user' do
#         invite_advisor_by(advisor_user.email)
# 
#         within '.advisor-invitation-dialog' do
#           click_link 'Add as an user'
#         end
# 
#         wait_until { page.has_no_css?('.advisor-invitation-dialog') }
# 
#         within '#company-affiliations table.users' do
#           page.should have_content(advisor_user.name)
#           page.should have_content(advisor_user.email)
#         end
# 
#         affiliations = company.user_affiliations
#         affiliations.should have(2).items
#         affiliations.where(user_id: advisor_user.id).should exist
#       end
# 
#       scenario 'add user company as an advisor' do
#         invite_advisor_by(advisor_user.email)
# 
#         within '.advisor-invitation-dialog form.advisor-companies-selection' do
#           click_button 'Invite'
#         end
# 
#         wait_until { page.has_no_css?('.advisor-invitation-dialog') }
# 
#         within '#company-affiliations table.users' do
#           page.should have_content(advisor_company.name)
#         end
# 
#         affiliations = company.advisor_company_affiliations
#         affiliations.should have(1).item
#         affiliations.where(advisor_company_id: advisor_company.id).should exist
#       end
#     end
# 
#     context 'when the given advisor user has several advisor companies' do
#       scenario 'display advisor select dialog' do
#         invite_advisor_by(advisor_user.email)
# 
#         within '.advisor-invitation-dialog form.advisor-companies-selection' do
#           select second_advisor_company.name
#           click_button 'Invite'
#         end
# 
#         wait_until { page.has_no_css?('.advisor-invitation-dialog') }
# 
#         within '#company-affiliations table.users' do
#           page.should have_content(second_advisor_company.name)
#         end
# 
#         affiliations = company.advisor_company_affiliations
#         affiliations.should have(1).item
#         affiliations.where(advisor_company_id: second_advisor_company.id).should exist
#       end
#     end
#   end
# 
#   context 'when the company is an advisor' do
#     let!(:company) { create(:advisor_company, users: [user]) }
#     before { visit_company_settings_page }
# 
#     scenario 'should not display advisor select dialog' do
#       within 'form.form-add-user' do
#         fill_in 'email', with: advisor_user.email
#         click_button 'Invite'
#       end
# 
#       within '#company-affiliations table.users' do
#         page.should have_content(advisor_user.name)
#       end
# 
#       affiliation = company.user_affiliations.where(user: advisor_user).first
#       affiliation.should_not be_nil
# 
#       company.advisor_company_affiliations.should be_empty
#       advisor_company.advisor_company_affiliations.should be_empty
#       second_advisor_company.advisor_company_affiliations.should be_empty
# 
#       advisor_user.companies.should include(company)
#     end
#   end
# 
# end
