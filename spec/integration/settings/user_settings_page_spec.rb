require 'spec_helper'

feature 'User settings page', js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:other_user) { create(:user, email: 'other@user.com') }

  let!(:company) { create(:company, :with_country, :with_industry, users: [user]) }

  background do
    login_as(user)
    navigate_to('settings', 'user')
  end

  describe 'user setting form' do
    include Macros::Integration::Forms

    scenario 'an user can see the form' do
      within 'h2' do
        page.should have_content('User Settings')
      end

      within 'form#user-info' do
        page.should have_field('name', with: user.name)
        page.should have_field('email', with: user.email)
        page.should have_unchecked_field('user_email_notifications')
      end
    end

    scenario 'update user info' do
      # Change name
      expect do
        fill_in_and_blur 'user_name', with: 'New user name'
        user.reload
      end.to change(user, :name).to('New user name')

      # Change email
      expect do
        fill_in_and_blur 'user_email', with: 'new@email.com'
        user.reload
      end.to change(user, :email).to('new@email.com')

      within '#user-settings-menu button' do
        page.should have_content('new@email.com')
      end
    end

    scenario 'change email notifications setting', :notifications do
      expect do
        page.find('#user_email_notifications_label').click()
        wait_until_saved('user_email_notifications')
        user.reload
      end.to change(user, :email_notifications).to(true)

      expect do
        uncheck 'user_email_notifications'
        wait_until_saved('user_email_notifications')
        user.reload
      end.to change(user, :email_notifications).to(false)
    end

    scenario 'show validation errors' do
      fill_in_and_blur('user_name', with: '') do
        within "span.indicator.validation-error.user_name" do
          page.should have_content("Can't be blank")
        end
      end

      fill_in_and_blur('user_email', with: '') do
        within "span.indicator.validation-error.user_email" do
          page.should have_content("Can't be blank, Is not an email address")
        end
      end

      fill_in_and_blur('user_email', with: 'invalid email') do
        within "span.indicator.validation-error.user_email" do
          page.should have_content("Is not an email address")
        end
      end

      fill_in_and_blur('user_email', with: 'other@user.com') do
        within "span.indicator.validation-error.user_email" do
          page.should have_content("is already taken")
        end
      end
    end

    scenario 'change avatar' do
      email = 'don.draper@sterlingcooper.com'
      fill_in_and_blur('user_email', with: email)

      within '.avatar' do
        img_src = "/assets/fake_avatars/avatar-8.jpg"
        page.should have_selector(:xpath, "//img[contains(@src,'#{img_src}')]")
      end
    end
  end

end
