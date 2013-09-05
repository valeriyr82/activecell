module Macros
  module UserLogin
    def login_as(user, options = {})
      login_with(user.email, options)
    end

    def login_with(email, options = {})
      options.reverse_merge!(password: 'password')
      options.reverse_merge!(login_page: root_path)

      visit options[:login_page]
      within 'form#new_user' do
        fill_in 'user_email', with: email
        fill_in 'user_password', with: options[:password]

        click_button 'Log in'
      end
    end

    def logout(user)
      visit root_path

      within '.container' do
        click_button user.email
        click_link 'Log out'
      end
    end
  end
end
