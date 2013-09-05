# Workaround for parallel tests and mongoid issue
# @see https://github.com/grosser/parallel_tests/issues/31
namespace :db do
  desc "Stub out to use with parallel_tests gem without ActiveRecord"
  task :abort_if_pending_migrations do
  end
end
