require 'spec_helper'

feature 'Company settings page', js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:company) { create(:company, :with_country, :with_industry, users: [user]) }

  let!(:other_country) { create(:country) }
  let!(:other_industry) { create(:industry) }

  background do
    login_as(user)
    navigate_to('settings', 'company')
  end

  describe 'basic info form' do
    include Macros::Integration::Forms

    scenario 'an user can see the form' do
      within 'h2' do
        page.should have_content('Company Settings')
      end

      within 'form#company-basic-info' do
        page.should have_field('name', with: company.name)
        page.should have_field('address_1', with: company.address_1)
        page.should have_field('address_2', with: company.address_2)
        page.should have_field('postal_code', with: company.postal_code)
        page.should have_field('url', with: company.url)

        page.should have_select('country_id', selected: company.country.name)
        page.should have_select('industry_id', selected: company.industry.name)
      end
    end

    scenario 'update basic info' do
      # Change name
      expect do
        fill_in_and_blur 'company_name', with: 'New company name'
        company.reload
      end.to change(company, :name).to('New company name')

      # Change address_1
      expect do
        fill_in_and_blur 'company_address_1', with: 'Cracov'
        company.reload
      end.to change(company, :address_1).to('Cracov')

      # Change address_2
      expect do
        fill_in_and_blur 'company_address_2', with: 'Some street 123'
        company.reload
      end.to change(company, :address_2).to('Some street 123')

      # Change url
      expect do
        fill_in_and_blur 'company_url', with: 'http://awesome.com'
        company.reload
      end.to change(company, :url).to('http://awesome.com')

      # Change country
      expect do
        select_and_blur('company_country_id', other_country.name)
        company.reload
      end.to change(company, :country).to(other_country)

      expect do
        select_and_blur('company_country_id', 'Not selected')
        company.reload
      end.to change(company, :country).to(nil)

      # Change industry
      expect do
        select_and_blur('company_industry_id', other_industry.name)
        company.reload
      end.to change(company, :industry).to(other_industry)

      expect do
        select_and_blur('company_industry_id', 'Not selected')
        company.reload
      end.to change(company, :industry).to(nil)
    end

    scenario 'show validation errors' do
      fill_in_and_blur('company_name', with: '') do
        within "span.indicator.validation-error.company_name" do
          page.should have_content("Can't be blank")
        end
      end

      fill_in_and_blur('company_url', with: '') do
        within "span.indicator.validation-error.company_url" do
          page.should have_content("Can't be blank, Is not an url address")
        end
      end

      fill_in_and_blur('company_url', with: 'invalid url') do
        within "span.indicator.validation-error.company_url" do
          page.should have_content("Is not an url address")
        end
      end
    end
  end
end
