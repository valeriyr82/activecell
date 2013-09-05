class Recurly < Thor

  desc 'update_plans', 'Update recurly plans from application.yml config file'
  def update_plans
    boot_rails!

    plans.each do |code, plan|
      unit_amount_in_cents = plan['unit_amount_in_cents'].to_i
      interval_length = plan['period'].to_i
      trial_interval_length = plan['trial_interval_length'].to_i

      begin
        # update the plan
        recurly_plan = ::Recurly::Plan.find(code)
        puts "Updating plan (#{code}): #{recurly_plan.inspect}"

        recurly_plan.name = plan['name']
        recurly_plan.unit_amount_in_cents = {
            default_currency => unit_amount_in_cents
        }
        recurly_plan.plan_interval_length = interval_length
        recurly_plan.trial_interval_length = trial_interval_length

        recurly_plan.save
      rescue ::Recurly::Resource::NotFound
        # create a new plan
        puts "Creating plan (#{code})"
        recurly_plan = ::Recurly::Plan.create(
            plan_code: code,
            name: plan['name'],
            unit_amount_in_cents: {
                default_currency => unit_amount_in_cents
            },
            plan_interval_length: interval_length,
            trial_interval_length: trial_interval_length
        )
      end

      update_add_ons_for!(recurly_plan)
    end

    delete_not_defined_plans!
  end

  desc 'list_plans', 'List recurly plans'
  def list_plans
    boot_rails!

    ::Recurly::Plan.find_each do |plan|
      puts "Plan name: #{plan.name}"
      puts "  code: #{plan.plan_code}"
      puts "  price: #{plan.unit_amount_in_cents}"
      puts "  interval length: #{plan.plan_interval_length}"
      puts '-' * 16
    end
  end

  private

  def boot_rails!
    require './config/environment'
  end

  def default_currency
    'USD'
  end

  def update_add_ons_for!(recurly_plan)
    plan = plans[recurly_plan.plan_code.to_sym]
    add_ons = plan['add_ons'] || []

    add_ons.each do |code, add_on|
      begin
        recurly_add_on = recurly_plan.add_ons.find(code)
        puts "Updating plan add-on (#{recurly_add_on.inspect})"

        recurly_add_on.update_attributes(
            name: add_on['name'],
            unit_amount_in_cents: add_on['unit_amount_in_cents']
        )
      rescue ::Recurly::API::NotFound
        puts "Creating plan add-on (#{code})"
        recurly_add_on = recurly_plan.add_ons.create(
            add_on_code: code,
            name: add_on['name'],
            unit_amount_in_cents: add_on['unit_amount_in_cents']
        )
      end
    end

    delete_not_defined_add_ons_for!(recurly_plan)
  end

  def delete_not_defined_plans!
    defined_plan_codes = plans.keys
    ::Recurly::Plan.find_each do |plan|
      unless defined_plan_codes.include?(plan.plan_code)
        puts "Deleting plan with code: #{plan.plan_code}"
        plan.destroy
      end
    end
  end

  def delete_not_defined_add_ons_for!(recurly_plan)
    plan = plans[recurly_plan.plan_code.to_sym]
    defined_add_on_codes = (plan['add_ons'] || {}).keys
    recurly_plan.add_ons.find_each do |add_on|
      unless defined_add_on_codes.include?(add_on.add_on_code)
        puts "Deleting plan with code: #{add_on.add_on_code}"
        add_on.destroy
      end
    end
  end

  def plans
    @plans ||= Settings.recurly.plans
  end

end
