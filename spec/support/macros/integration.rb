module Macros

  module Integration

    def visit_and_check(from, to)
      visit from
      current_url.gsub(/\/$/, '').should == "http://#{to}".gsub(/\/$/, '')
    end

    # TODO refactor this method
    def navigate_to(main, sub = nil, analysis = nil, id = nil)
      within "ul.main-nav li[data-original-title='#{main.downcase}']" do
        find('a').click
      end

      if sub
        within 'ul.sub-nav' do
          click_on(sub)
        end
      end

      if id
        within 'ul.sub-nav' do
          click_on('list')
        end
        within 'ul.items' do
          click_on(id)
        end
      end

      if analysis
        within 'ul.analysis-nav' do
          click_on(analysis)
        end
      end
    end

    def reload_app
      visit(current_url)
    end

    def take_screenshot
      page.driver.render('/tmp/screenshot.png', full: true)
    end

    def should_load_sign_in_page
      page.should have_content('Log in')

      within 'form#new_user' do
        page.should have_field('user_email')
        page.should have_field('user_password')
        page.should have_button('Log in')
      end
    end

    def confirm_dialog(message = 'Are you sure?')
      # TODO for some reason css selector does not work here
      modal_xpath = '//div[contains(@class, "bootbox")]'

      begin
        wait_until do
          not page.all(:xpath, modal_xpath).empty?
        end
      rescue Capybara::TimeoutError
        flunk 'Expected confirmation modal to be visible.'
      end

      within :xpath, modal_xpath do
        page.should have_content(message)
        click_link 'OK'
      end
    end

    # Waits until application for the given company is loaded
    # Checks whether the welcome page for selected company was loaded
    def should_load_application_for(company)
      # wait until metrics page is loaded
      wait_until { page.has_css?('#metrics-container') }

      within('.head-buttons') do
        page.should have_button(company.name)
      end

      within 'button.user-settings' do
        page.should have_content(company.name)
      end
    end

    # wait for ajax complete
    # TODO we could replace with wait for a spinner in the header
    def wait_for_ajax_complete
      wait_until { page.evaluate_script 'jQuery.active == 0' rescue true }
    end

    module Forms
      # Fill in the field with given id and trigger blur event
      # If block is given executes it
      #   otherwise it waits until field is saved
      def fill_in_and_blur(field_id, options = {})
        within 'form' do
          fill_in field_id, with: options[:with]
          page.execute_script("$('##{field_id}').trigger('blur');")

          if block_given?
            yield
          else
            wait_until_saved(field_id)
          end
        end
      end

      def select_and_blur(field_id, value)
        within 'form' do
          select value, from: field_id
          page.execute_script("$('##{field_id}').trigger('change');")
          wait_until_saved(field_id)
        end
      end

      def check_and_blur(field_id)
        within 'form' do
          check field_id
          wait_until_saved(field_id)
        end
      end

      def uncheck_and_blur(field_id)
        within 'form' do
          uncheck field_id
          wait_until_saved(field_id)
        end
      end

      def wait_until_saved(field_id)
        # wait for the success message
        within "span.indicator.#{field_id}" do
          wait_until { page.has_content?('Saved') }
        end
      end
    end

    module Recurly

      # Here be dragons!
      # This code executes javascript code in the integration test and stubs following JSONP calls:
      # * fetching location
      # * fetching plan data (used for rendering a form)
      # * creating a subscription
      def stub_recurly_jsonp_calls(options = {})
        stub_fetching_location!
        stub_fetching_plan!
        stub_subscribe!(options[:token])
        stub_update_billing_info!(options[:token])
      end

      private

      def stub_fetching_location!
        Capybara.current_session.execute_script <<-JS
          $.mockjax({
            url: new RegExp('api.recurly.com/jsonp/profitably/location'),
            dataType: 'jsonp',
            responseText: {
              "country": "PL",
              "state": "77",
              "city": "Cracow",
              "postal": null
            }
          });
        JS
      end

      def stub_fetching_plan!
        Capybara.current_session.execute_script <<-JS
          $.mockjax({
            url: new RegExp('api.recurly.com/jsonp/profitably/plans/monthly'),
            dataType: 'jsonp',
            data: {
              currency: "USD"
            },
            responseText: {
              "plan_code": "monthly",
              "name": "Activecell Monthly",
              "success_url": "",
              "display_quantity": false,
              "payment_page_tos_link": null,
              "setup_fee_in_cents": 0,
              "plan_interval_length": 1,
              "plan_interval_unit": "months",
              "trial_interval_unit": "days",
              "unit_amount_in_cents": 4999,
              "currency": "USD",
              "add_ons": []
            }
          });
        JS
      end

      def stub_subscribe!(token)
        Capybara.current_session.execute_script <<-JS
          $.mockjax({
            url: new RegExp('api.recurly.com/jsonp/profitably/subscribe'),
            dataType: 'jsonp',
            responseText: {
              "success": {
                "token": "#{token}"
              }
            }
          });
        JS
      end

      def stub_update_billing_info!(token)
        Capybara.current_session.execute_script <<-JS
          $.mockjax({
            url: new RegExp('api.recurly.com/jsonp/profitably/accounts/.+/billing_info'),
            dataType: 'jsonp',
            responseText: {
              "success": {
                "token": "#{token}"
              }
            }
          });
        JS
      end

    end

  end

end
