shared_examples 'quick company creation' do |options|
  companies_count = options[:number_of_displayed_companies]

  scenario 'create company' do
    # Add a company
    click_link 'Add a new company'

    within 'form#company-for-advisor' do
      fill_in 'company_name', with: 'Another Company'
      fill_in 'company_subdomain', with: 'anothercompany'
      click_button 'Create'
    end

    # Should add a company to the list
    wait_until { page.has_selector?('table tbody tr', count: companies_count) }

    within "table tbody tr:nth-child(#{companies_count})" do
      page.should have_content('Another Company')
    end

    # Should hide the form
    page.should have_no_selector '#company-for-advisor'
    page.should have_selector '#add-company'

    # Should create valid company record
    create_company = Company.last
    create_company.name.should == 'Another Company'
    create_company.subdomain.should == 'anothercompany'
  end

  scenario 'should prefill subdomain field automatically' do
    click_link 'Add a new company'

    within 'form#company-for-advisor' do
      fill_in 'company_name', with: 'another company'
      find('#company_subdomain').value.should == 'another-company'
    end
  end
end
