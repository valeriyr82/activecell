require 'spec_helper'

feature 'Reset password', :auth do
  let!(:company) { create(:company) }
  let!(:user) { create(:user, companies: [company], email: 'user@email.com') }

  background do
    visit new_user_session_path
    click_link 'Forgot your password?'
  end

  scenario 'an user can see new password request form' do
    page.should have_content('Forgot your password?')

    within 'form#new_user' do
      page.should have_field('user_email', type: 'email')
      page.should have_button('Reset password')
    end
  end

  describe 'when user request a new password' do
    background do
      fill_in 'user_email', with: 'user@email.com'
      click_button 'Reset password'
      open_email 'user@email.com'
    end

    describe 'reset password email' do
      subject { current_email }

      its(:from) { should include('support@activecell.com') }
      its(:to) { should include('user@email.com') }
      its(:subject) { should == 'Reset password instructions' }

      it { should have_link('Change my password') }
    end

    describe 'when the user follows link in the email' do
      background do
        current_email.click_link 'Change my password'
      end

      scenario 'an user can see reset password form' do
        page.should have_content('Change your password')

        within 'form#new_user' do
          page.should have_field('user_password', type: 'password')
          page.should have_field('user_password_confirmation', type: 'password')

          page.should have_button('Change my password')
        end
      end

      context 'when the user provides a new password' do
        let(:new_password) { 'this is a new password' }

        background do
          within 'form#new_user' do
            fill_in 'user_password', with: new_password
            fill_in 'user_password_confirmation', with: new_password
            click_button 'Change my password'
          end
        end

        scenario 'user should be able to login with his new password' do
          user.reload.valid_password?(new_password).should be_true
        end
      end
    end
  end
end
