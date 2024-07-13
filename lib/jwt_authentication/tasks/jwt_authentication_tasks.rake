# lib/tasks/jwt_authentication.rake

# Load all tasks from the jwt_authentication directory
Dir[File.join(__dir__, 'jwt_authentication', '*.rake')].each { |f| load f }

namespace :jwt_authentication do
  desc "Generate appropriate tests based on the testing framework"
  task generate_tests: :environment do
    if defined?(RSpec)
      Rake::Task['jwt_authentication:generate_rspec_tests'].invoke
    elsif defined?(MiniTest::Unit::TestCase)
      Rake::Task['jwt_authentication:generate_fixtures'].invoke
      Rake::Task['jwt_authentication:generate_minitest_tests'].invoke
    else
      puts "No recognized testing framework found. Please install RSpec or MiniTest."
    end
  end
end
